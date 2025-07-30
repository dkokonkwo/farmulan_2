import 'package:farmulan/farm/bottom_buttons.dart';
import 'package:farmulan/farm/plant_data.dart';
import 'package:farmulan/farm/plants.dart';
import 'package:farmulan/farm/sensor_tabs.dart';
import 'package:farmulan/farm/toggle_chart.dart';
import 'package:farmulan/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../utils/constants/plant_details_appbar.dart';

class PlantDetails extends StatefulWidget {
  final PlantInfo data;
  const PlantDetails({super.key, required this.data});

  @override
  State<PlantDetails> createState() => _PlantDetailsState();
}

class _PlantDetailsState extends State<PlantDetails> {
  int currentIndex = 0;

  void toggleButton(int index) {
    setState(() {
      currentIndex = index;
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
