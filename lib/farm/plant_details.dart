import 'dart:convert';

import 'package:farmulan/farm/bottom_buttons.dart';
import 'package:farmulan/farm/plant_data.dart';
import 'package:farmulan/farm/plants.dart';
import 'package:farmulan/farm/sensor_tabs.dart';
import 'package:farmulan/farm/toggle_chart.dart';
import 'package:farmulan/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';

import '../authentication/auth.dart';
import '../utils/constants/plant_details_appbar.dart';
import '../utils/constants/toasts.dart';

class PlantDetails extends StatefulWidget {
  final PlantInfo data;
  const PlantDetails({super.key, required this.data});

  @override
  State<PlantDetails> createState() => _PlantDetailsState();
}

class _PlantDetailsState extends State<PlantDetails> {
  int currentIndex = 0;
  bool _isOn = false;
  final box = Hive.box('farmulanDB');
  static const _irrigateNode = 'irrigate.json';

  void toggleButton(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  Future<void> waterOn() async {
    final user = Auth().currentUser;
    if (user == null) {
      showErrorToast(context, 'User not signed in');
      return;
    }

    final farmId = box.get('farmId') as String? ?? '';
    final cropId = widget.data.cropId;
    if (farmId.isEmpty || cropId.isEmpty) {
      showErrorToast(context, 'No farmId or cropId');
      return;
    }

    final uri = Uri.parse(
      'https://iot-farminc-default-rtdb.firebaseio.com'
      '/users/${user.uid}'
      '/farms/$farmId'
      '/crops/$cropId'
      '/$_irrigateNode',
    );

    try {
      // Use PUT and send a raw JSON string "ON"
      final response = await http.put(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode("ON"),
      );
      if (response.statusCode != 200) {
        throw Exception(
          'Failed to send irrigation ON (status ${response.statusCode}): ${response.body}',
        );
      }
    } catch (e) {
      if (!mounted) return;
      showErrorToast(context, 'Could not send ON command: $e');
      return;
    }

    setState(() {
      _isOn = true;
    });
  }

  Future<void> waterOff() async {
    final user = Auth().currentUser;
    if (user == null) {
      showErrorToast(context, 'User not signed in');
      return;
    }

    final farmId = box.get('farmId') as String? ?? '';
    final cropId = widget.data.cropId;
    if (farmId.isEmpty || cropId.isEmpty) {
      showErrorToast(context, 'No farmId or cropId');
      return;
    }

    final uri = Uri.parse(
      'https://iot-farminc-default-rtdb.firebaseio.com'
      '/users/${user.uid}'
      '/farms/$farmId'
      '/crops/$cropId'
      '/$_irrigateNode',
    );

    try {
      final response = await http.put(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode("OFF"),
      );
      if (response.statusCode != 200) {
        throw Exception(
          'Failed to send irrigation OFF (status ${response.statusCode}): ${response.body}',
        );
      }
    } catch (e) {
      if (!mounted) return;
      showErrorToast(context, 'Could not send OFF command: $e');
      return;
    }

    setState(() {
      _isOn = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: PlantDetailsAppBar(plantInfo: widget.data),
      body: widget.data.isGrowing
          ? SingleChildScrollView(
              child: Center(
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    ToggleChart(),
                    SizedBox(height: 20),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 20,
                      children: [
                        SensorTab(
                          icon: sensorIcons[currentIndex][0],
                          title: sensorFields[currentIndex][0],
                          value: sensorValues[currentIndex][0],
                        ),
                        SensorTab(
                          icon: sensorIcons[currentIndex][1],
                          title: sensorFields[currentIndex][1],
                          value: sensorValues[currentIndex][1],
                        ),
                      ],
                    ),
                    SizedBox(height: 15),
                    currentIndex == 3
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            spacing: 20,
                            children: [
                              ElevatedButton(
                                onPressed: waterOn,
                                style: ElevatedButton.styleFrom(
                                  elevation: 0.0,
                                  shadowColor: Colors.transparent,
                                  backgroundColor: AppColors.primaryRed,
                                  fixedSize: Size(screenWidth / 2.5, 57),
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  'Run Irrigation',
                                  style: TextStyle(
                                    fontFamily: 'Zen Kaku Gothic Antique',
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.pageBackground,
                                  ),
                                ),
                              ),
                              (_isOn ?? false)
                                  ? ElevatedButton(
                                      onPressed: waterOff,
                                      style: ElevatedButton.styleFrom(
                                        elevation: 0.0,
                                        shadowColor: Colors.transparent,
                                        backgroundColor: AppColors.primaryRed,
                                        fixedSize: Size(screenWidth / 2.5, 57),
                                        padding: EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        'Turn Off Irrigation',
                                        style: TextStyle(
                                          fontFamily: 'Zen Kaku Gothic Antique',
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.pageBackground,
                                        ),
                                      ),
                                    )
                                  : SizedBox.shrink(),
                            ],
                          )
                        : SizedBox.shrink(),
                  ],
                ),
              ),
            )
          : Center(child: StartPlanting()),
      bottomNavigationBar: widget.data.isGrowing
          ? Container(
              width: screenWidth,
              height: screenHeight / 7,
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Center(child: BottomButtons(changeIndex: toggleButton)),
            )
          : null,
    );
  }
}

class StartPlanting extends StatelessWidget {
  const StartPlanting({super.key});

  @override
  Widget build(BuildContext context) {
    BorderRadius bigRadius = BorderRadius.circular(20.0);
    BorderRadius mediumRadius = BorderRadius.circular(17.0);
    final width = MediaQuery.of(context).size.width / 1.12;
    const bgColor = AppColors.pageBackground;
    const offset = Offset(4, 4);
    const smallBlur = 8.0;
    final smallRadius = BorderRadius.circular(10);
    final gradient = LinearGradient(
      colors: [
        AppColors.primaryPurple,
        AppColors.primaryRed,
        AppColors.primaryPurple,
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Container(
      padding: EdgeInsets.all(3),
      decoration: BoxDecoration(borderRadius: bigRadius, gradient: gradient),
      child: Container(
        width: width,
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: mediumRadius,
          color: AppColors.pageBackground,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 40),
            SizedBox(
              height: width,
              child: Lottie.asset('assets/animations/startPlanting.json'),
            ),
            SizedBox(height: 40),

            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: smallRadius,
                  color: bgColor,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.topShadow,
                      blurRadius: smallBlur,
                      offset: -offset,
                    ),
                    BoxShadow(
                      color: AppColors.bottomShadow,
                      blurRadius: smallBlur,
                      offset: offset,
                    ),
                  ],
                ),
                child: Text(
                  'Start Growing',
                  style: TextStyle(
                    fontFamily: 'Zen Kaku Gothic Antique',
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryPurple,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
