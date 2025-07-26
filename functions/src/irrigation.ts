import { onCall, HttpsError } from 'firebase-functions/v2/https';
import * as logger from 'firebase-functions/logger';
import * as admin from 'firebase-admin';
import { fetchWeatherApi } from 'openmeteo';
import { onSchedule } from 'firebase-functions/v2/scheduler';
import fetch from 'node-fetch';

// Start writing functions
// https://firebase.google.com/docs/functions/typescript
admin.initializeApp();
const db = admin.firestore();

interface GetFarmDataRequest {
  userId?: string;
  farmId: string;
}

// interface GetFarmDataResponse {
//   elevation: number;
// }

export const getFarmData = onCall<GetFarmDataRequest, { elevation: number }>(
  async (request) => {
    const { data, auth } = request;

    if (!auth?.uid) {
      logger.warn('Unauthenticated call to getFarmData');
      throw new HttpsError('unauthenticated', 'You must be signed in.');
    }

    if (data.userId && data.userId !== auth.uid) {
      logger.warn(`UID ${auth.uid} tried to read ${data.userId}`);
      throw new HttpsError(
        'permission-denied',
        'Cannot read another user’s farm data.',
      );
    }

    const farmId = data.farmId;
    if (!farmId) {
      throw new HttpsError('invalid-argument', 'farmId required');
    }

    const farmRef = db
      .collection('users')
      .doc(auth.uid)
      .collection('farms')
      .doc(farmId);

    const snap = await farmRef.get();
    if (!snap.exists) {
      throw new HttpsError('not-found', `Farm ${farmId} not found`);
    }

    const farm = snap.data()!;
    const coord = farm.coord as admin.firestore.GeoPoint | undefined;
    if (!coord) {
      throw new HttpsError('internal', 'coord not set');
    }

    const lat = coord.latitude;
    const lon = coord.longitude;
    if (typeof lat !== 'number' || typeof lon !== 'number') {
      throw new HttpsError('internal', 'coord malformed');
    }

    const elevationResp = await fetchElevation(lat, lon);
    const elevation = Array.isArray(elevationResp.elevation)
      ? elevationResp.elevation[0]
      : undefined;

    if (typeof elevation !== 'number') {
      throw new HttpsError('internal', 'Bad elevation payload');
    }

    await farmRef.update({
      'meteorData.elevation': elevation,
      'meteorData.latitude': lat,
    });

    logger.info(`Farm ${farmId} elevation set to ${elevation}`);

    return { elevation };
  },
);

/**
 * Calls the Open‑Meteo elevation API and returns the raw JSON response.
 *
 * @param {number} lat - The latitude to look up.
 * @param {number} lon - The longitude to look up.
 * @return {Promise<{ elevation: number[] }>}
 */
async function fetchElevation(lat: number, lon: number) {
  const url =
    'https://api.open-meteo.com/v1/elevation?' +
    `latitude=${lat}&longitude=${lon}`;
  const resp = await fetch(url);
  if (!resp.ok) {
    const text = await resp.text();
    logger.error(`Elevation API ${resp.status}`, text);
    throw new HttpsError('internal', `Elevation API error ${resp.status}`);
  }
  return resp.json();
}

export const scheduledMeteorUpdate = onSchedule(
  '0 0 * * *', // Runs daily at midnight UTC
  {
    timezone: 'Etc/UTC',
    timeoutSeconds: 540,
  },
  async (event) => {
    logger.log('Starting scheduledMeteorUpdate...');

    try {
      // List all user documents
      const usersRefs = await db.collection('users').listDocuments();
      logger.info(`Found ${usersRefs.length} user(s).`);

      for (const userRef of usersRefs) {
        // List all farm documents for each user
        const farmsRefs = await userRef.collection('farms').listDocuments();
        logger.info(`User ${userRef.id} has ${farmsRefs.length} farm(s).`);

        for (const farmRef of farmsRefs) {
          try {
            const farmSnap = await farmRef.get();
            if (!farmSnap.exists) {
              logger.warn(
                `Farm document ${farmRef.path} does not exist, skipping.`,
              );
              continue;
            }

            const farm = farmSnap.data()!;
            const coord = farm.coord as admin.firestore.GeoPoint | undefined;

            if (!coord) {
              logger.warn(`Farm ${farmRef.path} missing coord; skipping`);
              continue;
            }

            const lat = coord.latitude;
            const lon = coord.longitude;

            // Optional: Basic validation for lat/lon
            if (typeof lat !== 'number' || typeof lon !== 'number') {
              logger.warn(
                `Farm ${farmRef.path} has malformed coordinates; skipping`,
              );
              continue;
            }

            const today = dayOfTheYear(); // Get current day of the year

            // Call getMeteorData (make sure it's defined and imported/scoped correctly)
            const meteorData = await getMeteorData(lat, lon); // <--- Correctly await the call

            await farmRef.update({
              'meteorData.tMax': meteorData.tMax,
              'meteorData.tMin': meteorData.tMin,
              'meteorData.sunshineDuration': meteorData.sunshineDuration,
              'meteorData.rhMax': meteorData.rhMax,
              'meteorData.rhMin': meteorData.rhMin,
              'meteorData.windSpeed': meteorData.windSpeed,
              'meteorData.height': meteorData.height,
              'meteorData.latitude': meteorData.latitude,
              'meteorData.longitude': meteorData.longitude, // Add longitude here
              'meteorData.dayOfYear': today + 1, // forecast is for tomorrow, this is fine
            });

            logger.info(`Updated meteorData for farm ${farmRef.path}`);
          } catch (farmError: any) {
            logger.error(`Error processing farm ${farmRef.path}:`, farmError);
            // Continue to the next farm even if one fails
          }
        }
      }
      logger.log('ScheduledMeteorUpdate completed successfully.');
    } catch (mainError: any) {
      logger.error('Error in scheduledMeteorUpdate main loop:', mainError);
      // Re-throw the error to indicate failure to Cloud Functions
      throw mainError;
    }
  },
);

function dayOfTheYear() {
  const today = new Date();
  return Math.ceil((today - new Date(today.getFullYear(), 0, 1)) / 86400000);
}

async function getMeteorData(lat: number, lon: number) {
  const params = {
    latitude: lat,
    longitude: lon,
    daily: [
      'temperature_2m_max',
      'temperature_2m_min',
      'sunshine_duration',
      'wind_speed_10m_max',
    ],
    hourly: ['temperature_2m', 'relative_humidity_2m', 'wind_speed_10m'],
    current: ['temperature_2m', 'relative_humidity_2m', 'wind_speed_10m'],
    timezone: 'auto',
    forecast_days: 1,
  };

  const url = 'https://api.open-meteo.com/v1/forecast';
  let responses: any;
  try {
    responses = await fetchWeatherApi(url, params);
  } catch (error: any) {
    logger.error('Error fetching Open-Meteo API data:', error);
    throw new HttpsError(
      'internal',
      'Failed to fetch weather data from Open-Meteo.',
      error.message,
    );
  }

  // Process first location. Add a for-loop for multiple locations or weather models
  const response = responses[0];

  // Attributes for timezone and location
  const utcOffsetSeconds = response.utcOffsetSeconds();
  const timezone = response.timezone();
  const timezoneAbbreviation = response.timezoneAbbreviation();
  const latitude = response.latitude();
  const longitude = response.longitude();

  const current = response.current()!;
  const hourly = response.hourly()!;
  const daily = response.daily()!;

  // Note: The order of weather variables in the URL query and the indices below need to match!
  const weatherData = {
    current: {
      time: new Date((Number(current.time()) + utcOffsetSeconds) * 1000),
      temperature2m: current.variables(0)!.value(),
      relativeHumidity2m: current.variables(1)!.value(),
      windSpeed10m: current.variables(2)!.value(),
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
      temperature2m: hourly.variables(0)!.valuesArray()!,
      relativeHumidity2m: hourly.variables(1)!.valuesArray()!,
      windSpeed10m: hourly.variables(2)!.valuesArray()!,
    },
    daily: {
      time: [
        ...Array(
          (Number(daily.timeEnd()) - Number(daily.time())) / daily.interval(),
        ),
      ].map(
        (_, i) =>
          new Date(
            (Number(daily.time()) + i * daily.interval() + utcOffsetSeconds) *
              1000,
          ),
      ),
      temperature2mMax: daily.variables(0)!.valuesArray()!,
      temperature2mMin: daily.variables(1)!.valuesArray()!,
      sunshineDuration: daily.variables(2)!.valuesArray()!,
      windSpeed10mMax: daily.variables(3)!.valuesArray()!,
    },
  };

  // Calculate the average wind speed, max humidity and min humidity for first day forecast
  let totalSpeed = 0;
  let minHumidity =
    weatherData.hourly.relativeHumidity2m.length > 0
      ? weatherData.hourly.relativeHumidity2m[0]
      : 101;
  let maxHumidity =
    weatherData.hourly.relativeHumidity2m.length > 0
      ? weatherData.hourly.relativeHumidity2m[0]
      : -1;

  if (weatherData.hourly.relativeHumidity2m.length > 0) {
    for (let i = 0; i < weatherData.hourly.time.length; i++) {
      totalSpeed += weatherData.hourly.windSpeed10m[i];
      const currentHumValue = weatherData.hourly.relativeHumidity2m[i];
      minHumidity =
        currentHumValue < minHumidity ? currentHumValue : minHumidity;
      maxHumidity =
        currentHumValue > maxHumidity ? currentHumValue : maxHumidity;
    }
  } else {
    logger.warn('No hourly humidity data found.');
    // Decide how to handle this: throw an error, return default values, etc.
    // For now, let's set default or indicate an error.
    // Or ensure the loop below handles empty array gracefully
  }

  averageWindSpeed = totalSpeed / (weatherData.hourly.time.length || 1);

  const i = 0; // first day forecast
  const meteorData = {
    tMax: weatherData.daily.temperature2mMax[i],
    tMin: weatherData.daily.temperature2mMax[i],
    sunshineDuration: weatherData.daily.sunshineDuration[i],
    rhMax: maxHumidity,
    rhMin: minHumidity,
    windSpeed: averageWindSpeed,
    height: 10,
    latitude: lat,
  };
  return meteorData;
}
