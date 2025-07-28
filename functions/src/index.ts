import { setGlobalOptions } from 'firebase-functions/v2';
import { onRequest } from 'firebase-functions/https';
import { onCall } from 'firebase-functions/v2/https';
import * as logger from 'firebase-functions/logger';
import * as admin from "firebase-admin";
import {tomatoDuration, tomatoKc} from './stages';

export { getFarmData, scheduledMeteorUpdate } from './irrigation';

// Start writing functions
// https://firebase.google.com/docs/functions/typescript
setGlobalOptions({ maxInstances: 10 });


admin.initializeApp();
const db = admin.firestore();

// export const helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

// fetchWeather data from api: moved function to backend(Cloud functions)
// interface WeatherData {
//   coord: { lat: number; lon: number };
//   weather: any[]; // you can define a more specific type here
//   base: string;
//   main: Record<string, any>; // or a properly shaped interface
//   visibility: number;
//   wind: Record<string, any>;
//   clouds: Record<string, any>;
//   dt: number;
//   sys: Record<string, any>;
//   timezone: number;
//   id: number;
//   name: string;
//   cod: number;
// }

export const fetchWeather = onRequest(async (request, response) => {
  logger.info('Request received', { structuredData: true });

  if (request.method !== 'POST') {
    response.status(405).send('Method Not Allowed');
    return;
  }

  // Ensure request body is parsed as JSON
  let coord: [number, number];
  try {
    if (typeof request.body === 'string') {
      // If the body is a string, try parsing it as JSON
      const parsedBody = JSON.parse(request.body);
      coord = parsedBody.coord;
    } else {
      // Assume it's already a parsed object
      coord = request.body.coord;
    }
  } catch (parseError: any) {
    logger.error('Failed to parse request body as JSON', parseError);
    response.status(400).send('Invalid JSON in request body');
    return;
  }

  if (
    !coord ||
    !Array.isArray(coord) ||
    coord.length !== 2 ||
    typeof coord[0] !== 'number' ||
    typeof coord[1] !== 'number'
  ) {
    response
      .status(400)
      .send("Missing or invalid 'coord' in request body. Expected [lat, lon]");
    return;
  }

  const rapidApiKey = process.env.OPENWEATHER_KEY;
  logger.info(rapidApiKey);

  if (!rapidApiKey) {
    logger.error('RapidAPI key not configured.');
    response.status(500).send('Server configuration error: API key missing.');
    return;
  }

  const [lat, lon] = coord;
  const url = `
  https://open-weather13.p.rapidapi.com/latlon?latitude=${lat}&longitude=${lon}&lang=EN
  `;
  const options = {
    method: 'GET',
    headers: {
      'x-rapidapi-key': rapidApiKey,
      'x-rapidapi-host': 'open-weather13.p.rapidapi.com',
    },
  };

  try {
    const fetchRes = await fetch(url, options);
    if (!fetchRes.ok) {
      const errorText = await fetchRes.text(); // Read error body for more info
      logger.error(`API returned non-OK status: ${fetchRes.status}`, {
        responseBody: errorText,
      });
      throw new Error(`API returned ${fetchRes.status}: ${errorText}`);
    }
    const result = await fetchRes.json(); // Expect JSON response
    response.json(result); // Send back as JSON
  } catch (err: any) {
    logger.error('Weather fetch failed', {
      error: err.message,
      stack: err.stack,
    });
    response
      .status(500)
      .send(`Error fetching weather: ${err.message || 'Unknown error'}`);
  }
});

export const buildCropStages = onCall(async (request) => {
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

          const cropId = data.cropId;
          if (!cropId) {
              throw new HttpsError("invalid-argument", "cropId required");
          }

          const cropRef = db
            .collection("users").doc(auth.uid)
            .collection("farms").doc(farmId)
            .collection("crops").doc(cropId);

          const snap = await cropRef.get();
          if (!snap.exists) {
            throw new HttpsError("not-found", `Crop ${cropId} not found`);
          }

          const crop = snap.data()!;
          const plantedTs = crop.timePlanted as admin.firestore.Timestamp | undefined;
          if (!plantedTs) {
            throw new HttpsError("failed precondition", "timePlanted not set");
          }

          const plantedDate = plantedTs.toDate();
          const yearStart   = new Date(plantedDate.getFullYear(), 0, 1);
          plantingDayOfYear =  Math.ceil(
              (today.getTime() - yearStart.getTime()) / 86400000);

          let stages = [];

          if (crop.name == 'tomato') {
              const t0 = plantingDayOfYear;
              const t1 = t0 + tomatoDuration[0];                // end of initial
              const t2 = t1 + tomatoDuration[1];                // end of development
              const t3 = t2 + tomatoDuration[2];                // end of mid‑season
              const t4 = t3 + tomatoDuration[3];

              stages = [
                  // initial → development: Kc_ini → Kc_mid
                    { start: t0, end: t1, Kc0: tomatoKc[0], Kc1: tomatoKc[1] },

                    // development → mid‑season: Kc_mid → Kc_mid (flat)
                    { start: t1, end: t2, Kc0: tomatoKc[1], Kc1: tomatoKc[1] },

                    // mid‑season → late: Kc_mid → Kc_end
                    { start: t2, end: t3, Kc0: tomatoKc[1], Kc1: tomatoKc[2] },

                    // late stage ends at harvest: Kc_end → Kc_end (flat or falling)
                    { start: t3, end: t4, Kc0: tomatoKc[2], Kc1: tomatoKc[2] },
                  ];
          }

            await cropRef.update({
                "stages": stages,
                });

          logger.info(`Crop ${cropId} stages set`);

          return {stages};
          }
}
