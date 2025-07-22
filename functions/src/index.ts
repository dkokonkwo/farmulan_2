import {setGlobalOptions} from "firebase-functions/v2";
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

  if (request.method !== "POST") {
    response.status(405).send("Method Not Allowed");
    return;
  }

  // Ensure request body is parsed as JSON
  let coord: [number, number];
  try {
    if (typeof request.body === "string") {
      // If the body is a string, try parsing it as JSON
      const parsedBody = JSON.parse(request.body);
      coord = parsedBody.coord;
    } else {
      // Assume it's already a parsed object
      coord = request.body.coord;
    }
  } catch (parseError: any) {
    logger.error("Failed to parse request body as JSON", parseError);
    response.status(400).send("Invalid JSON in request body");
    return;
  }

  if (!coord || !Array.isArray(coord) || coord.length !== 2 ||
  typeof coord[0] !== "number" || typeof coord[1] !== "number") {
    response.status(400).send(
      "Missing or invalid 'coord' in request body. Expected [lat, lon]"
    );
    return;
  }

  const rapidApiKey = process.env.OPENWEATHER_KEY;
  logger.info(rapidApiKey);

  if (!rapidApiKey) {
    logger.error("RapidAPI key not configured.");
    response.status(500).send("Server configuration error: API key missing.");
    return;
  }

  const [lat, lon] = coord;
  const url = `
  https://open-weather13.p.rapidapi.com/latlon?latitude=${lat}&longitude=${lon}&lang=EN
  `;
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
      const errorText = await fetchRes.text(); // Read error body for more info
      logger.error(
        `API returned non-OK status: ${fetchRes.status}`,
        {responseBody: errorText});
      throw new Error(`API returned ${fetchRes.status}: ${errorText}`);
    }
    const result = await fetchRes.json(); // Expect JSON response
    response.json(result); // Send back as JSON
  } catch (err: any) {
    logger.error(
      "Weather fetch failed", {error: err.message, stack: err.stack}
    );
    response.status(500).send(
      `Error fetching weather: ${err.message || "Unknown error"}`
    );
  }
});

