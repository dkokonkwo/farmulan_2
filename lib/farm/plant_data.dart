// Weekly Sensors data
import 'package:flutter/material.dart';

import '../utils/constants/icons.dart';

final List<int> weeklyTemps = [12, 3, 18, 0, 7, 15, 9];
final List<int> weeklyLight = [4, 17, 1, 14, 8, 2, 11];
final List<int> weeklySoilMoisture = [5, 5, 18, 6, 13, 10, 0];
final List<int> weeklyHumidity = [8, 10, 14, 15, 13, 10, 16];

// stages of growth
final List<String> plantStages = [
  'Germination',
  'Seedling',
  'Vegetative',
  'Budding',
  'Harvest',
];

final List<List<String>> plantAppBarData = [
  ['Tomatoes', '8', plantStages[2], 'Growing'],
  ['Lettuce', '10', plantStages[3], 'Growing'],
  ['Maize', '8', plantStages[4], 'Growing'],
  ['Cassava', '2', plantStages[1], 'Growing'],
];

final List<List<IconData>> sensorIcons = [
  [AppIcons.temp, AppIcons.temp],
  [AppIcons.sun, AppIcons.sun],
  [AppIcons.drop, AppIcons.wind],
  [AppIcons.timer, AppIcons.calendar],
];

final List<List<String>> sensorFields = [
  ['Max Temp', 'Current Temp'],
  ['Max. Intensity', 'Current Intensity'],
  ['Soil moisture', 'Humidity'],
  ['Last Irrigated', 'Next irrigation'],
];

final List<List<String>> sensorValues = [
  ['25°c', '10°c'],
  ['1000 Lux', '650 Lux'],
  ['30%', '25%'],
  ['5:30am', '6:30pm'],
];
