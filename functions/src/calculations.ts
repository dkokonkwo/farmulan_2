/* eslint-disable camelcase */
/* eslint-disable @typescript-eslint/no-non-null-assertion */
/* eslint-disable require-jsdoc */
/**
 * The meteorological inputs you fetch from Open‑Meteo.
 */
export interface ProcessedMeteorData {
  tMax: number;
  tMin: number;
  sunshineDuration: number;
  daylightDuration: number;
  rainfall: number; // gross rainfall [mm]
  rhMax: number; // [%]
  rhMin: number; // [%]
  windSpeed: number; // [m/s]
  height: number; // anemometer height [m]
  latitude: number; // [°]
  longitude: number; // [°]
  dayOfYear: number;
  elevation: number;
}

/**
 * One entry in your `stages` array for Kc interpolation.
 */
export interface Stage {
  start: number; // day‐of‐year inclusive
  end: number; // day‐of‐year inclusive
  Kc0: number; // Kc at start
  Kc1: number; // Kc at end
}

/**
 * What your computeDailyIrrigation function will return.
 */
export interface IrrigationResult {
  ETo: number; // reference evapotranspiration [mm/day]
  Kc_today: number; // today’s interpolated Kc
  ETc: number; // actual crop evapotranspiration [mm/day]
  IR: number; // net irrigation requirement [mm/day]
}

/**
 * The parameter object for the FAO‑56 ETo calculator (Eq.6).
 */
export interface EToParams {
  Δ: number; // slope of vapour‐pressure curve [kPa/°C]
  Rn: number; // net radiation [MJ/m²day]
  G: number; // soil heat flux [MJ/m²day]
  γ: number; // psychrometric constant [kPa/°C]
  T: number; // mean air temperature [°C]
  u2: number; // wind speed at 2m [m/s]
  es: number; // mean saturation vapour pressure [kPa]
  ea: number; // actual vapour pressure [kPa]
}

export async function computeDailyIrrigation(
  meteorData: ProcessedMeteorData,
  cropStages: Stage[],
) {
  // 1. Atmos pressure & psych constant
  const {
    tMax,
    tMin,
    sunshineDuration,
    daylightDuration,
    rainfall,
    rhMax,
    rhMin,
    windSpeed,
    height,
    latitude,
    dayOfYear,
    elevation,
  } = meteorData;
  const P = calcAtmosphericPressure(elevation);
  const γ = calcPsychrometricConstant(P);
  const IE = 0.8;

  // 2. Vapor pressures
  const eTmax = calcSvp(tMax);
  const eTmin = calcSvp(tMin);
  const es = calcMeanSvp(eTmax, eTmin);
  const ea = calcActualVaporPressure(eTmax, eTmin, rhMax, rhMin);

  // 3. Curve slope
  const Tmean = (tMax + tMin) / 2;
  const Δ = calcSlopeCurve(Tmean);

  // 4. Radiation terms
  const Ra = calcExtraterrestrialRadiation(latitude, dayOfYear);
  const Nmax = daylightDuration;
  const Rs = calcSolarRadiation(Ra, sunshineDuration, Nmax);
  const Rso = calcClearSkySolarRadiation(elevation, Ra);
  const Rns = calcNetShortwave(Rs);
  const Rnl = calcNetLongwave(tMax, tMin, ea, Rs, Rso);
  const Rn = Rns - Rnl;
  const G = 0;

  // 5. Wind at 2m
  const u2 = calcWind2(windSpeed, height);

  // 6. Reference ET
  const ETo = calcETo({Δ, Rn, G, γ, T: Tmean, u2, es, ea});

  // 7. Kc today
  const Kc_today = interpKc(dayOfYear, cropStages);

  // 8. ETc and IR
  const ETc = calcETc(ETo, Kc_today);
  const Reff = 0.7 * rainfall;
  const IR = calcIR(ETc, Reff, IE);
  return {ETo, ETc, IR};
}

// Irrigation calculations
// 1. Atmospheric pressure [kPa]
function calcAtmosphericPressure(altitude_m: number) {
  // FAO‑56 Eq.7
  return 101.3 * Math.pow((293 - 0.0065 * altitude_m) / 293, 5.26);
}

// 2. Psychrometric constant [kPa°C⁻¹]
function calcPsychrometricConstant(P_kPa: number) {
  // FAO‑56 Eq.8
  return 0.000665 * P_kPa;
}

// 3. Saturation vapour pressure at temperature T [kPa]
function calcSvp(T_C: number) {
  // FAO‑56 Eq.11
  return 0.6108 * Math.exp((17.27 * T_C) / (T_C + 237.3));
}

// 4. Mean daily saturation vapour pressure [kPa]
function calcMeanSvp(eTmax_kPa: number, eTmin_kPa: number) {
  return (eTmax_kPa + eTmin_kPa) / 2;
}

// 5. Actual vapour pressure [kPa]
//    using RHmin & RHmax method (FAO‑56 Eq.12)
function calcActualVaporPressure(
  eTmax_kPa: number,
  eTmin_kPa: number,
  RHmax_pct: number,
  RHmin_pct: number,
) {
  return ((eTmin_kPa * RHmax_pct) / 100 + (eTmax_kPa * RHmin_pct) / 100) / 2; // Note: some sources average; adjust if needed
}

// 6. Slope of saturation vapour‑pressure curve [kPa°C⁻¹]
//    at mean temperature T [FAO‑56 Eq.13]
function calcSlopeCurve(T_C: number) {
  const es = calcSvp(T_C);
  return (4098 * es) / Math.pow(T_C + 237.3, 2);
}

// 7. Extraterrestrial radiation Ra [MJm⁻²day⁻¹]
//    This one’s a bit long—FAO‑56 AppendixA
function calcExtraterrestrialRadiation(
  latitude_deg: number,
  julianDay: number,
) {
  const φ = (latitude_deg * Math.PI) / 180;
  const dr = 1 + 0.033 * Math.cos(((2 * Math.PI) / 365) * julianDay);
  const δ = 0.409 * Math.sin(((2 * Math.PI) / 365) * julianDay - 1.39);
  const ωs = Math.acos(-Math.tan(φ) * Math.tan(δ));
  const Gsc = 0.082; // solar constant [MJm⁻²min⁻¹]
  // daily Ra
  return (
    ((24 * 60) / Math.PI) *
    Gsc *
    dr *
    (ωs * Math.sin(φ) * Math.sin(δ) + Math.cos(φ) * Math.cos(δ) * Math.sin(ωs))
  );
}

// 8. Solar radiation Rs [MJm⁻²day⁻¹]
//    from sunshine hours (Angström) [FAO‑56 Eq.34]
function calcSolarRadiation(
  Ra: number,
  sunshine_h: number,
  Nmax_h: number,
  as = 0.25,
  bs = 0.5,
) {
  return (as + bs * (sunshine_h / Nmax_h)) * Ra;
}

// 9. Net shortwave radiation Rns [MJm⁻²day⁻¹]
function calcNetShortwave(Rs: number, albedo = 0.23) {
  return (1 - albedo) * Rs;
}

// 10. Net longwave radiation Rnl [MJm⁻²day⁻¹]
//     FAO‑56 Eq.39
function calcNetLongwave(
  Tmax_C: number,
  Tmin_C: number,
  ea_kPa: number,
  Rs: number,
  Rso: number,
) {
  // Stefan‑Boltzmann constant σ = 4.903×10⁻⁹ MJK⁻⁴m⁻²day⁻¹
  const σ = 4.903e-9;
  const term1 =
    (Math.pow(Tmax_C + 273.16, 4) + Math.pow(Tmin_C + 273.16, 4)) / 2;
  const term2 = 0.34 - 0.14 * Math.sqrt(ea_kPa);
  const term3 = 1.35 * (Rs / Rso) - 0.35;
  return σ * term1 * term2 * term3;
}

//    Rso = clear‑sky solar radiation [FAO‑56 Eq.37]
function calcClearSkySolarRadiation(altitude_m: number, Ra: number) {
  return (0.75 + 2e-5 * altitude_m) * Ra;
}

// 11. Wind speed corrected to 2m height [ms⁻¹]
//     FAO‑56 Eq.47
function calcWind2(u_z: number, z: number) {
  return u_z * (4.87 / Math.log(67.8 * z - 5.42));
}

// 12. FAO‑56 Penman‐Monteith: Reference ETo [mmday⁻¹]
//     FAO‑56 Eq.6
/**
 * Calculate reference evapotranspiration (ETo) using the FAO‑56 Penman‑Monteith equation.
 *
 * @param params Δ    Slope of vapour‑pressure curve [kPa°C⁻¹]
 *               Rn   Net radiation  [MJm⁻²day⁻¹]
 *               G    Soil heat flux [MJm⁻²day⁻¹] (defaults to 0 for daily timestep)
 *               γ    Psychrometric constant [kPa°C⁻¹]
 *               T    Mean air temp at 2m [°C]
 *               u2   Wind speed at 2m [ms⁻¹]
 *               es   Mean saturation vapour pressure [kPa]
 *               ea   Actual vapour pressure [kPa]
 * @return       ETo [mmday⁻¹]
 */
/* eslint-disable-next-line @typescript-eslint/explicit-module-boundary-types */
export function calcETo(params: EToParams): number {
  const {
    Δ, // slope curve [kPa°C⁻¹]
    Rn, // net radiation [MJm⁻²day⁻¹]
    G = 0, // soil heat flux [MJm⁻²day⁻¹]
    γ, // psychrometric constant [kPa°C⁻¹]
    T, // mean air temp [°C]
    u2, // wind speed at 2m [ms⁻¹]
    es, // mean saturation vapour pressure [kPa]
    ea, // actual vapour pressure [kPa]
  } = params;

  const numerator =
    0.408 * Δ * (Rn - G) + γ * (900 / (T + 273)) * u2 * (es - ea);

  const denominator = Δ + γ * (1 + 0.34 * u2);

  return numerator / denominator;
}

// 13. Interpolate Kc for today
function interpKc(
  dayOfYear: number,
  stages: Array<{ start: number; end: number; Kc0: number; Kc1: number }>,
) {
  // stages = [{ start: d0, end: d1, Kc0, Kc1 }] …
  for (const s of stages) {
    if (dayOfYear >= s.start && dayOfYear <= s.end) {
      const frac = (dayOfYear - s.start) / (s.end - s.start);
      return s.Kc0 + frac * (s.Kc1 - s.Kc0);
    }
  }
  throw new Error("Day outside all stages");
}

// 14. Crop evapotranspiration [mm day–¹]
function calcETc(ETo: number, Kc_today: number) {
  return ETo * Kc_today;
}

// 15. Net irrigation requirement [mm day–¹]
function calcIR(ETc: number, Reff: number, IE: number) {
  return Math.max(0, (ETc - Reff) / IE);
}
