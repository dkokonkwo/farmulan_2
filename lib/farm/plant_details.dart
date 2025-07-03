import 'package:farmulan_2/farm/bottom_buttons.dart';
import 'package:farmulan_2/farm/plant_data.dart';
import 'package:farmulan_2/farm/sensor_tabs.dart';
import 'package:farmulan_2/farm/toggle_chart.dart';
import 'package:farmulan_2/utils/constants/colors.dart';
import 'package:flutter/material.dart';

import '../utils/constants/plant_details_appbar.dart';

class PlantDetails extends StatefulWidget {
  final int index;
  const PlantDetails({super.key, required this.index});

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
      appBar: PlantDetailsAppBar(plantInfo: plantAppBarData[widget.index]),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              SizedBox(height: 50),
              ToggleChart(),
              SizedBox(height: 40),
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
      ),
      bottomNavigationBar: Container(
        width: screenWidth,
        height: screenHeight / 7,
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Center(child: BottomButtons(changeIndex: toggleButton)),
      ),
    );
  }
}
