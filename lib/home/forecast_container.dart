import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmulan/authentication/auth.dart';
import 'package:farmulan/home/weather_property.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';

import '../utils/constants/colors.dart';
import '../utils/constants/icons.dart';
import '../utils/constants/plant_details_appbar.dart';
import '../utils/constants/toasts.dart';

class WeatherInfo extends StatefulWidget {
  const WeatherInfo({super.key});

  @override
  State<WeatherInfo> createState() => _WeatherInfoState();
}

class _WeatherInfoState extends State<WeatherInfo> {
  final _myBox = Hive.box('farmulanDB');

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _myBox.listenable(keys: ['location']),
      builder: (context, Box b, _) {
        final loc = b.get('location', defaultValue: [0.0, 0.0]) as List<double>;

        return loc[0] != 0.0 ? WeatherAPIData(coordinates: loc) : GPSLocator();
      },
    );
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
    // _fetchWeather();
  }

  Future<void> _setCityAndCountry(String city, String country) async {
    // save farm location's city and country to firestore if not saved already
    final user = Auth().currentUser;
    if (user == null) {
      showErrorToast(context, 'User not signed in');
      return;
    }

    final myBox = Hive.box('farmulanDB');
    final farmId = myBox.get('farmId') as String?;
    if (farmId == null || farmId.isEmpty) {
      showErrorToast(context, 'No farm selected');
      return;
    }

    try {
      final farmRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('farms')
          .doc(farmId);

      final snapshot = await farmRef.get();
      final data = snapshot.data() ?? {};
      final needsCity = (data['city'] as String?)?.isEmpty ?? true;
      final needsCountry = (data['country'] as String?)?.isEmpty ?? true;

      if (needsCity || needsCountry) {
        await farmRef.set({
          if (needsCity) 'city': city,
          if (needsCountry) 'country': country,
        }, SetOptions(merge: true));
      }

      // store locally as well
      final String? savedCity = myBox.get('city') as String?;

      // If we haven't, write both city & country
      if (savedCity == null || savedCity.isEmpty) {
        await myBox.put('city', city);
        await myBox.put('country', country);

        if (!mounted) return;
        showSuccessToast(context, 'Saved farm city and country!');
      }
    } catch (e) {
      if (!mounted) return;
      showErrorToast(context, 'Failed to save city and country: $e');
    }
  }

  Future<void> _fetchWeather() async {
    final uri = Uri.parse('https://fetchweather-e4ldvx4z3a-uc.a.run.app');
    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'coord': widget.coordinates}),
      );
      if (response.statusCode != 200) {
        throw Exception(
          'Failed to fetch weather (status ${response.statusCode}): ${response.body}',
        );
      }
      final data = json.decode(response.body) as Map<String, dynamic>;
      if (!mounted) return;
      setState(() {
        country = data['sys']['country'];
        city = data['name'];
        humidity = data['main']['humidity'];
        wind = (data['wind']['speed'] as num) * 3.6;
        temp = (data['main']['temp'] as num) - 273.15;
        description = data['weather'][0]['description'];
        icon = data['weather'][0]['icon'];
      });
      await _setCityAndCountry(city, country);
    } catch (e) {
      if (!mounted) return;
      showErrorToast(context, 'Could not load weather: $e');
    }
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
                    style: TextStyle(
                      fontFamily: 'Zen Kaku Gothic Antique',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.mainBg,
                    ),
                  ),
                  Text(
                    country,
                    style: TextStyle(
                      fontFamily: 'Zen Kaku Gothic Antique',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.mainBg,
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
                  icon.isNotEmpty
                      ? Image.network(
                          'https://openweathermap.org/img/wn/$icon@2x.png',
                          width: 30,
                          height: 30,
                          fit: BoxFit.cover,
                        )
                      : SizedBox(
                          width: 30,
                          height: 30,
                          child: Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.pageBackground,
                            ),
                          ),
                        ),
                  SizedBox(width: 10),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.mainBg.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
              Text(
                '${temp.toStringAsFixed(1)}°C',
                style: TextStyle(
                  fontFamily: 'Zen Kaku Gothic Antique',
                  fontSize: 25,
                  fontWeight: FontWeight.w600,
                  color: AppColors.mainBg,
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

  void _askForLocation() async {
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
              style: const TextStyle(
                fontFamily: 'Zen Kaku Gothic Antique',
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: AppColors.primaryRed,
              ),
            ),
          ],
        ),
      ),
    );

    final user = Auth().currentUser;
    if (user == null) {
      showErrorToast(context, 'User not signed in');
      return;
    }

    if (!await Geolocator.isLocationServiceEnabled()) {
      if (!mounted) return;
      showErrorToast(context, 'Location services are disabled.');
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
      showErrorToast(context, 'Location permission denied.');
      return;
    }

    // fetch the position and store in hive
    Position pos;

    // Create a new farm document with auto-ID, then set its data
    try {
      pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final farmRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('farms')
          .doc();

      final farmId = farmRef.id;
      await farmRef.set({
        'coord': GeoPoint(pos.latitude, pos.longitude),
        'createdAt': Timestamp.now(),
      });

      if (mounted) Navigator.of(context, rootNavigator: true).pop();

      await _myBox.put('location', [pos.latitude, pos.longitude]);
      await _myBox.put('farmId', farmId);
      if (!mounted) return;
      showSuccessToast(context, 'Farm created with ID $farmId');
    } catch (e) {
      if (!mounted) return;
      showErrorToast(context, 'Failed to get location or set farm details: $e');
    }
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
            style: TextStyle(
              fontFamily: 'Zen Kaku Gothic Antique',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          NeumorphicButton(icon: AppIcons.gps, onTap: _askForLocation),
        ],
      ),
    );
  }
}
