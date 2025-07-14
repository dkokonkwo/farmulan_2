import 'dart:convert';

import 'package:farmulan/home/weather_property.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:toastification/toastification.dart';

import '../utils/constants/colors.dart';
import '../utils/constants/icons.dart';
import '../utils/constants/plant_details_appbar.dart';

class WeatherInfo extends StatefulWidget {
  const WeatherInfo({super.key});

  @override
  State<WeatherInfo> createState() => _WeatherInfoState();
}

class _WeatherInfoState extends State<WeatherInfo> {
  final _myBox = Hive.box('farmulanDB');

  @override
  Widget build(BuildContext context) {
    List<double> location = _myBox.get('location', defaultValue: [0.0, 0.0]);
    print(location);
    return location[0] != 0.0
        ? WeatherAPIData(coordinates: location)
        : GPSLocator();
  }
}

class WeatherAPIData extends StatefulWidget {
  final List<double> coordinates;
  const WeatherAPIData({super.key, required this.coordinates});

  @override
  State<WeatherAPIData> createState() => _WeatherAPIDataState();
}

class _WeatherAPIDataState extends State<WeatherAPIData> {
  String country = '';
  String city = '';
  int humidity = 0;
  double wind = 0.0;
  double temp = 0.0;
  String icon = '';
  String description = '';
  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  void _loadWeather() async {
    try {
      final data = await fetchWeather(widget.coordinates);
      setState(() {
        country = data['sys']['country'];
        city = data['name'];
        humidity = data['main']['humidity'];
        wind = (data['wind']['speed'] as double) * 3.6;
        temp = (data['main']['temp'] as double) - 273.15;
        description = data['weather'][0]['description'];
        icon = data['weather'][0]['icon'];
      });
    } catch (e) {
      String message = 'Error fetching weather: $e';
      showToast(context, message);
    }
  }

  Future<Map<String, dynamic>> fetchWeather(List<double> coordinates) async {
    final String lang = 'EN';
    final uri = Uri.https('open-weather13.p.rapidapi.com', '/latlon', {
      'latitude': coordinates[0].toString(),
      'longitude': coordinates[1].toString(),
      'lang': lang,
    });
    final response = await http.get(
      uri,
      headers: {
        'x-rapidapi-key': '13732c0a24msh0666500c322e5e7p15aebcjsnad58355b049c',
        'x-rapidapi-host': 'open-weather13.p.rapidapi.com',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception(
        'Failed to fetch weather (status ${response.statusCode}): ${response.body}',
      );
    }
  }

  void showToast(BuildContext context, Object message) {
    toastification.show(
      context: context,
      type: ToastificationType.error,
      // Change to error, warning, or info as needed
      style: ToastificationStyle.flat,
      title: const Text('Error!'),
      description: Text('$message'),
      autoCloseDuration: const Duration(seconds: 3),
      icon: const Icon(Icons.error, color: AppColors.pageBackground),
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width - 40;
    double height = MediaQuery.of(context).size.height / (844 / 120);
    return Container(
      height: height,
      width: width,
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryPurple, AppColors.primaryRed],
        ),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 8),
            blurRadius: 24,
            spreadRadius: 0,
            color: Colors.black.withValues(alpha: 0.4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    city,
                    style: GoogleFonts.zenKakuGothicAntique(
                      textStyle: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.mainBg,
                      ),
                    ),
                  ),
                  Text(
                    country,
                    style: GoogleFonts.zenKakuGothicAntique(
                      textStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.mainBg,
                      ),
                    ),
                  ),
                ],
              ),
              //   Temperature
              Row(
                spacing: 20.0,
                children: [
                  WeatherProp(
                    icon: AppIcons.drop,
                    title: 'Humidity',
                    value: '$humidity%',
                  ),

                  WeatherProp(
                    icon: AppIcons.wind,
                    title: 'NE Wind',
                    value: '${wind.toStringAsFixed(1)}km/h',
                  ),
                ],
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Image.network(
                    'https://openweathermap.org/img/wn/$icon@2x.png',
                    width: 30,
                    height: 30,
                    fit: BoxFit.cover,
                  ),
                  SizedBox(width: 10),
                  Text(
                    description,
                    style: GoogleFonts.zenKakuGothicAntique(
                      textStyle: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.mainBg.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                '${temp.toStringAsFixed(1)}°C',
                style: GoogleFonts.zenKakuGothicAntique(
                  textStyle: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w600,
                    color: AppColors.mainBg,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class GPSLocator extends StatefulWidget {
  const GPSLocator({super.key});

  @override
  State<GPSLocator> createState() => _GPSLocatorState();
}

class _GPSLocatorState extends State<GPSLocator> {
  final _myBox = Hive.box('farmulanDB');

  void _askForLocation() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.pageBackground,
        content: Column(
          spacing: 10.0,
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset('assets/animations/IoTloading.json'),
            Text(
              'Please wait, fetching Location...',
              textAlign: TextAlign.center,
              style: GoogleFonts.zenKakuGothicAntique(
                textStyle: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryRed,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    popDialog() {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    }

    _getLocation().whenComplete(popDialog);
  }

  Future<void> _getLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      if (!mounted) return;
      showToast(context, 'Location services are disabled.');
      return;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }

    if (permission != LocationPermission.always &&
        permission != LocationPermission.whileInUse) {
      if (!mounted) return;
      showToast(context, 'Location permission denied.');
      return;
    }

    // fetch the position and store
    try {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      await _myBox.put('location', [pos.latitude, pos.longitude]);
      setState(() {});
    } catch (e) {
      if (!mounted) return;
      showToast(context, e);
    }
  }

  void showToast(BuildContext context, Object message) {
    toastification.show(
      context: context,
      type: ToastificationType.error,
      // Change to error, warning, or info as needed
      style: ToastificationStyle.flat,
      title: const Text('Error!'),
      description: Text('$message'),
      autoCloseDuration: const Duration(seconds: 3),
      icon: const Icon(Icons.error, color: AppColors.pageBackground),
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width - 40;
    return Container(
      width: width,
      padding: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: AppColors.pageBackground,
        boxShadow: [
          BoxShadow(
            color: Color(0xff3B4056).withValues(alpha: 0.15),
            offset: Offset(0, 20),
            blurRadius: 40,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        spacing: 10.0,
        children: [
          Text(
            'If you’re standing at your farm right now, tap GPS button below to automatically fetch your location. '
            'Otherwise, go to your Profile page to manually add your farm location.',
            textAlign: TextAlign.center,
            style: GoogleFonts.zenKakuGothicAntique(
              textStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
          NeumorphicButton(icon: AppIcons.gps, onTap: _askForLocation),
        ],
      ),
    );
  }
}
