import {setGlobalOptions, config} from "firebase-functions/v2";
import {onRequest} from "firebase-functions/https";
import * as logger from "firebase-functions/logger";

// Start writing functions
// https://firebase.google.com/docs/functions/typescript
setGlobalOptions({maxInstances: 10});

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
  logger.info("Request received", {structuredData: true});

  // Only allow POST, and expect JSON
  if (request.method !== "POST") {
    response.status(405).send("Method Not Allowed");
    return;
  }

  const coord: [number, number] = request.body.coord;

  if (!coord || coord.length !== 2) {
    response.status(400).send("Missing or invalid 'coord' in request body");
    return;
  }

  const rapidApiKey = config().openweather.key as string;

  const [lat, lon] = coord;
  const url = `https://open-weather13.p.rapidapi.com/latlon?latitude=${lat}&longitude=${lon}&lang=EN`;
  const options = {
    method: "GET",
    headers: {
      "x-rapidapi-key": rapidApiKey,
      "x-rapidapi-host": "open-weather13.p.rapidapi.com",
    },
  };

  try {
    const fetchRes = await fetch(url, options);
    if (!fetchRes.ok) {
      throw new Error(`API returned ${fetchRes.status}`);
    }
    const result = await fetchRes.text();
    response.send(result);
  } catch (err: any) {
    logger.error("Weather fetch failed", err);
    response.status(500).send(`Error fetching weather: ${err.message || err}`);
  }
});

// save city and country if not saved
