
async function computeDailyIrrigation (farmData) {
     // 1. Atmos pressure & psych constant
      const P  = calcAtmosphericPressure(altitude);
      const γ  = calcPsychrometricConstant(P);

      // 2. Vapor pressures
      const eTmax = calcSvp(tMax);
      const eTmin = calcSvp(tMin);
      const es    = calcMeanSvp(eTmax, eTmin);
      const ea    = calcActualVaporPressure(eTmax, eTmin, rhMax, rhMin);

      // 3. Curve slope
      const Tmean = (tMax + tMin) / 2;
      const Δ     = calcSlopeCurve(Tmean);

      // 4. Radiation terms
      const Ra = calcExtraterrestrialRadiation(latitude, dayOfYear);
      const Nmax = daylightDuration;
      const Rs = calcSolarRadiation(Ra, sunshineDuration, Nmax);
      const Rso = calcClearSkySolarRadiation(altitude, Ra);
      const Rns = calcNetShortwave(Rs);
      const Rnl = calcNetLongwave(tMax, tMin, ea, Rs, Rso);
      const Rn  = Rns - Rnl;
      const G   = 0;

      // 5. Wind at 2m
      const u2 = calcWind2(windSpeed, height);

      // 6. Reference ET
      const ETo = calcETo({ Δ, Rn, G, γ, T: Tmean, u2, es, ea });

      // 7. Kc today
      const Kc_today = interpKc(dayOfYear, cropStages);

      // 8. ETc and IR
      const ETc = calcETc(ETo, Kc_today);
      const IR  = calcIR(ETc, Reff, IE);
}





// Irrigation calculations
// 1. Atmospheric pressure [kPa]
function calcAtmosphericPressure(altitude_m) {
  // FAO‑56 Eq.7
  return 101.3 * Math.pow((293 - 0.0065 * altitude_m) / 293, 5.26);
}

// 2. Psychrometric constant [kPa°C⁻¹]
function calcPsychrometricConstant(P_kPa) {
  // FAO‑56 Eq.8
  return 0.000665 * P_kPa;
}

// 3. Saturation vapour pressure at temperature T [kPa]
function calcSvp(T_C) {
  // FAO‑56 Eq.11
  return 0.6108 * Math.exp((17.27 * T_C) / (T_C + 237.3));
}

// 4. Mean daily saturation vapour pressure [kPa]
function calcMeanSvp(eTmax_kPa, eTmin_kPa) {
  return (eTmax_kPa + eTmin_kPa) / 2;
}

// 5. Actual vapour pressure [kPa]
//    using RHmin & RHmax method (FAO‑56 Eq.12)
function calcActualVaporPressure(eTmax_kPa, eTmin_kPa, RHmax_pct, RHmin_pct) {
  return (
    (eTmin_kPa * RHmax_pct / 100) +
    (eTmax_kPa * RHmin_pct / 100)
  ) / 2;  // Note: some sources average; adjust if needed

// 6. Slope of saturation vapour‑pressure curve [kPa°C⁻¹]
//    at mean temperature T [FAO‑56 Eq.13]
function calcSlopeCurve(T_C) {
  const es = calcSvp(T_C);
  return (4098 * es) / Math.pow((T_C + 237.3), 2);
}

// 7. Extraterrestrial radiation Ra [MJm⁻²day⁻¹]
//    This one’s a bit long—FAO‑56 AppendixA
function calcExtraterrestrialRadiation(latitude_deg, julianDay) {
  const φ = latitude_deg * Math.PI / 180;
  const dr = 1 + 0.033 * Math.cos((2 * Math.PI / 365) * julianDay);
  const δ = 0.409 * Math.sin((2 * Math.PI / 365) * julianDay - 1.39);
  const ωs = Math.acos(-Math.tan(φ) * Math.tan(δ));
  const Gsc = 0.0820;  // solar constant [MJm⁻²min⁻¹]
  // daily Ra
  return (24 * 60 / Math.PI) *
         Gsc * dr *
         (ωs * Math.sin(φ) * Math.sin(δ) +
          Math.cos(φ) * Math.cos(δ) * Math.sin(ωs));
}

// 8. Solar radiation Rs [MJm⁻²day⁻¹]
//    from sunshine hours (Angström) [FAO‑56 Eq.34]
function calcSolarRadiation(Ra, sunshine_h, Nmax_h, as = 0.25, bs = 0.50) {
  return (as + bs * (sunshine_h / Nmax_h)) * Ra;
}

// 9. Net shortwave radiation Rns [MJm⁻²day⁻¹]
function calcNetShortwave(Rs, albedo = 0.23) {
  return (1 - albedo) * Rs;
}

// 10. Net longwave radiation Rnl [MJm⁻²day⁻¹]
//     FAO‑56 Eq.39
function calcNetLongwave(Tmax_C, Tmin_C, ea_kPa, Rs, Rso) {
  // Stefan‑Boltzmann constant σ = 4.903×10⁻⁹ MJK⁻⁴m⁻²day⁻¹
  const σ = 4.903e-9;
  const term1 = (Math.pow(Tmax_C + 273.16, 4) + Math.pow(Tmin_C + 273.16, 4)) / 2;
  const term2 = 0.34 - 0.14 * Math.sqrt(ea_kPa);
  const term3 = 1.35 * (Rs / Rso) - 0.35;
  return σ * term1 * term2 * term3;
}

//    Rso = clear‑sky solar radiation [FAO‑56 Eq.37]
function calcClearSkySolarRadiation(altitude_m, Ra) {
  return (0.75 + 2e-5 * altitude_m) * Ra;
}

// 11. Wind speed corrected to 2m height [ms⁻¹]
//     FAO‑56 Eq.47
function calcWind2(u_z, z) {
  return u_z * (4.87 / Math.log((67.8 * z) - 5.42));
}

// 12. FAO‑56 Penman‐Monteith: Reference ETo [mmday⁻¹]
//     FAO‑56 Eq.6
function calcETo({
  Δ,       // slope curve [kPa°C⁻¹]
  Rn,      // net radiation [MJm⁻²day⁻¹]
  G = 0,   // soil heat flux [MJm⁻²day⁻¹]
  γ,       // psychrometric constant [kPa°C⁻¹]
  T,       // mean air temp [°C]
  u2,      // wind speed at 2m [ms⁻¹]
  es,      // mean saturation vapour pressure [kPa]
  ea       // actual vapour pressure [kPa]
}) {
  const numerator =
    0.408 * Δ * (Rn - G) +
    γ * (900 / (T + 273)) * u2 * (es - ea);
  const denominator = Δ + γ * (1 + 0.34 * u2);
  return numerator / denominator;
}

// 13. Interpolate Kc for today
function interpKc(dayOfYear, stages) {
  // stages = [
  //   { start: d0, end: d1, Kc0, Kc1 }, …
  // ]
  for (let s of stages) {
    if (dayOfYear >= s.start && dayOfYear <= s.end) {
      const frac = (dayOfYear - s.start) / (s.end - s.start);
      return s.Kc0 + frac * (s.Kc1 - s.Kc0);
    }
  }
  throw new Error("Day outside all stages");
}

// 14. Crop evapotranspiration [mm day–¹]
function calcETc(ETo, Kc_today) {
  return ETo * Kc_today;
}

// 15. Net irrigation requirement [mm day–¹]
function calcIR(ETc, Reff, IE) {
  return Math.max(0, (ETc - Reff) / IE);
}