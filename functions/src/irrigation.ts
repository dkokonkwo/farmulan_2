/* eslint-disable camelcase */
/* eslint-disable @typescript-eslint/no-non-null-assertion */
/* eslint-disable require-jsdoc */
import {onCall, HttpsError} from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";
import * as admin from "firebase-admin";
import {fetchWeatherApi} from "openmeteo";
import {onSchedule, ScheduledEvent} from "firebase-functions/v2/scheduler";

import {
  computeDailyIrrigation,
  Stage,
  ProcessedMeteorData,
} from "./calculations";
// import fetch from "node-fetch";
// https://firebase.google.com/docs/functions/typescript
admin.initializeApp();
const db = admin.firestore();

interface GetFarmDataRequest {
  userId?: string;
  farmId: string;
}

interface SoilProfile {
  θ_fc: number; // field capacity [m³/m³]
  θ_wp: number; // wilting point  [m³/m³]
  Zr: number; // root depth [mm]
  p: number; // allowable depletion fraction (e.g. 0.5)
}

const soil: SoilProfile = {
  θ_fc: 0.3, // e.g. sandy loam
  θ_wp: 0.15,
  Zr: 300, // mm
  p: 0.5, // let it dry to 50% of TAW
};

export const getFarmData = onCall<
  GetFarmDataRequest,
  Promise<{ elevation: number }>
>(async (request) => {
  const {data, auth} = request;

  if (!auth?.uid) {
    logger.warn("Unauthenticated call to getFarmData");
    throw new HttpsError("unauthenticated", "You must be signed in.");
  }

  if (data.userId && data.userId !== auth.uid) {
    logger.warn(`UID ${auth.uid} tried to read ${data.userId}`);
    throw new HttpsError(
      "permission-denied",
      "Cannot read another user’s farm data.",
    );
  }

  const farmId = data.farmId;
  if (!farmId) {
    throw new HttpsError("invalid-argument", "farmId required");
  }

  const farmRef = db
    .collection("users")
    .doc(auth.uid)
    .collection("farms")
    .doc(farmId);

  const snap = await farmRef.get();
  if (!snap.exists) {
    throw new HttpsError("not-found", `Farm ${farmId} not found`);
  }

  const farm = snap.data()!;
  const coord = farm.coord as admin.firestore.GeoPoint | undefined;
  if (!coord) {
    throw new HttpsError("internal", "coord not set");
  }

  const lat = coord.latitude;
  const lon = coord.longitude;
  if (typeof lat !== "number" || typeof lon !== "number") {
    throw new HttpsError("internal", "coord malformed");
  }

  const elevationResp = await fetchElevation(lat, lon);
  const elevation = Array.isArray(elevationResp.elevation) ?
    elevationResp.elevation[0] :
    undefined;

  if (typeof elevation !== "number") {
    throw new HttpsError("internal", "Bad elevation payload");
  }

  await farmRef.update({
    "meteorData.elevation": elevation,
    "meteorData.latitude": lat,
  });

  logger.info(`Farm ${farmId} elevation set to ${elevation}`);

  return {elevation};
});

/**
 * Calls the Open‑Meteo elevation API and returns the raw JSON response.
 *
 * @param {number} lat - The latitude to look up.
 * @param {number} lon - The longitude to look up.
 * @return {Promise<{ elevation: number[] }>}
 */
async function fetchElevation(lat: number, lon: number) {
  const url =
    "https://api.open-meteo.com/v1/elevation?" +
    `latitude=${lat}&longitude=${lon}`;
  const resp = await fetch(url);
  if (!resp.ok) {
    const text = await resp.text();
    logger.error(`Elevation API ${resp.status}`, text);
    throw new HttpsError("internal", `Elevation API error ${resp.status}`);
  }
  return resp.json();
}

// daily schedule
export const scheduledMeteorUpdate = onSchedule(
  {
    schedule: "0 0,8,16 * * *", // This is the correct cron syntax
    timeZone: "Africa/Kigali", // Specify your timezone for accurate scheduling
  },
  async (event: ScheduledEvent) => {
    // <--- Event type for scheduled functions is 'ScheduleEvent'
    logger.log("Starting scheduledMeteorUpdate...");

    const users = await db.collection("users").listDocuments();
    logger.info(`Found ${users.length} user(s).`);

    for (const userRef of users) {
      const farms = await userRef.collection("farms").listDocuments();
      for (const farmRef of farms) {
        try {
          const farmSnap = await farmRef.get();
          if (!farmSnap.exists) continue;
          const farm = farmSnap.data()!;
          const coord = farm.coord as admin.firestore.GeoPoint | undefined;
          if (!coord) {
            logger.warn(`Farm ${farmRef.path} missing coord; skipping`);
            continue;
          }

          const meteorData = await getMeteorData(
            coord.latitude,
            coord.longitude,
          );
          await farmRef.update({meteorData});
          logger.info(`Updated meteorData for farm ${farmRef.path}`);

          const cropRefs = await farmRef.collection("crops").listDocuments();
          await setIrrigationSchedule(cropRefs, meteorData);
        } catch (err) {
          logger.error(`Farm ${farmRef.path} error`, err);
        }
      }
    }
    logger.log("ScheduledMeteorUpdate completed successfully.");
  },
);

async function setIrrigationSchedule(
  cropRefs: FirebaseFirestore.DocumentReference[],
  meteorData: ProcessedMeteorData,
): Promise<void> {
  for (const cropRef of cropRefs) {
    try {
      const snap = await cropRef.get();
      if (!snap.exists) {
        logger.warn(`Crop document ${cropRef.path} does not exist, skipping.`);
        continue;
      }

      const crop = snap.data()!;
      const stages = crop.stages as Stage[];
      const θ_current = crop.soilMoisture as number;

      if (!stages || θ_current == null) {
        logger.warn(
          `Crop ${cropRef.path} missing stages or soil moisture value; skipping`,
        );
        continue;
      }

      const {ETo, ETc, IR} = await computeDailyIrrigation(meteorData, stages);

      await cropRef.update({ETo, ETc, IR});

      const IE = 0.75; // sprinklers at 75% efficiency

      const daysToIrrigate = daysUntilIrrigation(soil, θ_current, ETc);
      if (daysToIrrigate === 0) {
        // start irrigation now:
        // send start to microcontroller
        const waterDepth = irrigationDepth(soil, θ_current, IE);
        logger.info(
          `Irrigate today with ${waterDepth.toFixed(1)} mm of water.`,
        );
        await cropRef.update({
          irrigating: true,
          waterDepth,
          lastIrrigated: admin.firestore.FieldValue.serverTimestamp(),
        });
      } else {
        await cropRef.update({
          irrigating: false,
          nextIrrigation: daysToIrrigate.toFixed(1),
        });
        logger.info(`Irrigation in ~${daysToIrrigate.toFixed(1)} days.`);
      }
      logger.info(`Updated updated irrigation schedule for ${cropRef.path}`);
    } catch (cropError: any) {
      logger.error(`Error scheduling crop ${cropRef.path}:`, cropError);
    }
  }
}

/**
 * Calculates day of year.
 * @return {number}
 */
function dayOfTheYear(): number {
  const today = new Date();
  const start = new Date(today.getFullYear(), 0, 1);
  return Math.ceil((today.getTime() - start.getTime()) / 86400000);
}

/**
 * Calls the Open‑Meteo meteorological API and returns the JSON response.
 *
 * @param {number} lat - The latitude to look up.
 * @param {number} lon - The longitude to look up.
 * @return {Promise<ProcessedMeteorData>}
 */
async function getMeteorData(
  lat: number,
  lon: number,
): Promise<ProcessedMeteorData> {
  const params = {
    latitude: lat,
    longitude: lon,
    daily: [
      "temperature_2m_max",
      "temperature_2m_min",
      "sunshine_duration",
      "wind_speed_10m_max",
      "daylight_duration",
      "precipitation_sum",
    ],
    hourly: ["temperature_2m", "relative_humidity_2m", "wind_speed_10m"],
    current: ["temperature_2m", "relative_humidity_2m", "wind_speed_10m"],
    timezone: "auto",
    forecast_days: 1,
  };
  const url = "https://api.open-meteo.com/v1/forecast";

  let responses: any;
  try {
    responses = await fetchWeatherApi(url, params);
  } catch (error: any) {
    logger.error("Error fetching Open-Meteo API data:", error);
    throw new HttpsError(
      "internal",
      "Failed to fetch weather data from Open-Meteo.",
      error.message,
    );
  }

  // Process first location. Add a for-loop for multiple locations or weather models
  const response = responses[0];

  const utcOffsetSeconds = response.utcOffsetSeconds();

  const current = response.current()!;
  const hourly = response.hourly()!;
  const daily = response.daily()!;

  // Note: The order of weather variables in the URL query and the indices below need to match!
  const weatherData = {
    current: {
      time: new Date((Number(current.time()) + utcOffsetSeconds) * 1000),
      temperature_2m: current.variables(0)!.value(),
      relative_humidity_2m: current.variables(1)!.value(),
      wind_speed_10m: current.variables(2)!.value(),
    },
    hourly: {
      time: [
        ...Array(
          (Number(hourly.timeEnd()) - Number(hourly.time())) /
            hourly.interval(),
        ),
      ].map(
        (_, i) =>
          new Date(
            (Number(hourly.time()) + i * hourly.interval() + utcOffsetSeconds) *
              1000,
          ),
      ),
      temperature_2m: hourly.variables(0)!.valuesArray(),
      relative_humidity_2m: hourly.variables(1)!.valuesArray(),
      wind_speed_10m: hourly.variables(2)!.valuesArray(),
    },
    daily: {
      time: [
        ...Array(
          (Number(daily.timeEnd()) - Number(daily.time())) / daily.interval(),
        ),
      ].map(
        (_, i) =>
          new Date(
            (Number(daily.time()) + i * hourly.interval() + utcOffsetSeconds) *
              1000,
          ),
      ),
      temperature_2m_max: daily.variables(0)!.valuesArray(),
      temperature_2m_min: daily.variables(1)!.valuesArray(),
      sunshine_duration: daily.variables(2)!.valuesArray(),
      wind_speed_10m_max: daily.variables(3)!.valuesArray(),
      daylight_duration: daily.variables(4)!.valuesArray(),
      precipitation_sum: daily.variables(5)!.valuesArray(),
    },
  };

  // Calculate the average wind speed, max humidity and min humidity for first day forecast
  let totalSpeed = 0;
  let minHumidity =
    weatherData.hourly.relative_humidity_2m.length > 0 ?
      weatherData.hourly.relative_humidity_2m[0] :
      101;
  let maxHumidity =
    weatherData.hourly.relative_humidity_2m.length > 0 ?
      weatherData.hourly.relative_humidity_2m[0] :
      -1;

  if (weatherData.hourly.relative_humidity_2m.length > 0) {
    for (let i = 0; i < weatherData.hourly.time.length; i++) {
      totalSpeed += weatherData.hourly.wind_speed_10m[i];
      const currentHumValue = weatherData.hourly.relative_humidity_2m[i];
      minHumidity =
        currentHumValue < minHumidity ? currentHumValue : minHumidity;
      maxHumidity =
        currentHumValue > maxHumidity ? currentHumValue : maxHumidity;
    }
  } else {
    logger.warn("No hourly humidity data found.");
  }

  const averageWindSpeed = totalSpeed / (weatherData.hourly.time.length || 1);

  const elevationResp = await fetchElevation(lat, lon);
  const elevation = Array.isArray(elevationResp.elevation) ?
    elevationResp.elevation[0] :
    undefined;

  const i = 0; // first day forecast
  const meteorData = {
    tMax: weatherData.daily.temperature_2m_max[i],
    tMin: weatherData.daily.temperature_2m_min[i],
    sunshineDuration: weatherData.daily.sunshine_duration[i],
    daylightDuration: weatherData.daily.daylight_duration[i],
    rainfall: weatherData.daily.precipitation_sum[i],
    rhMax: maxHumidity,
    rhMin: minHumidity,
    windSpeed: averageWindSpeed,
    height: 10,
    latitude: lat,
    longitude: lon,
    dayOfYear: dayOfTheYear(),
    elevation: elevation,
  };
  return meteorData;
}

function daysUntilIrrigation(
  soil: SoilProfile,
  θ_current: number, // current volumetric moisture [m³/m³]
  ETc: number, // crop evapotranspiration [mm/day]
): number {
  // Total available water (TAW) [mm]
  const TAW = (soil.θ_fc - soil.θ_wp) * soil.Zr;

  // Maximum allowable depletion Dr_max [mm]
  const Dr_max = soil.p * TAW;

  // Current water in root zone Su [mm]
  const Su = (θ_current - soil.θ_wp) * soil.Zr;

  // Threshold water remaining before irrigation
  const Su_threshold = TAW - Dr_max;

  if (Su <= Su_threshold) {
    return 0; // irrigate today
  }

  // Days until Su falls to threshold at rate ETc per day
  return (Su - Su_threshold) / ETc;
}

function irrigationDepth(
  soil: SoilProfile,
  θ_current: number,
  IE: number, // irrigation efficiency (0–1)
): number {
  // Water needed to refill to FC
  const depthToFC = (soil.θ_fc - θ_current) * soil.Zr;

  // Adjust for system efficiency
  return depthToFC / IE;
}
