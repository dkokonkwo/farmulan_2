import 'package:farmulan/farm/chart_dropdown.dart';
import 'package:farmulan/farm/plant_data.dart';
import 'package:farmulan/utils/constants/bar_chart.dart';
import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';

import '../utils/constants/colors.dart';

List<List<int>> weeklyData = [
  weeklyTemps,
  weeklyHumidity,
  weeklySoilMoisture,
  weeklyLight,
];

class ToggleChart extends StatefulWidget {
  const ToggleChart({super.key});

  @override
  State<ToggleChart> createState() => _ToggleChartState();
}

class _ToggleChartState extends State<ToggleChart> {
  final List<String> timeLengths = ['1D', '1W', '1M'];
  late String currentTimeLength;
  int currentData = 0;

  @override
  void initState() {
    super.initState();
    currentTimeLength = timeLengths.first;
  }

  void changeData(int index) {
    setState(() {
      currentData = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    BorderRadius smallRadius = BorderRadius.circular(10.0);
    BorderRadius bigRadius = BorderRadius.circular(20.0);
    Offset buttonOffset = Offset(4, 4);
    double buttonBlurRadius = 8.0;
    double blur = 30.0;
    Offset distance = Offset(20, 20);
    final width = MediaQuery.of(context).size.width / 1.11;

    return Container(
      width: width,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: bigRadius,
        color: AppColors.pageBackground,
        boxShadow: [
          BoxShadow(
            color: AppColors.white,
            blurRadius: blur,
            offset: -distance,
          ),
          BoxShadow(
            blurRadius: blur,
            offset: distance,
            color: AppColors.bottomShadow,
          ),
        ],
      ),
      child: Column(
        spacing: 10,
        children: [
          Row(
            spacing: 5,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ChartDropdown(onChange: changeData),
              Row(
                spacing: 15,
                children: timeLengths.map((value) {
                  final bool isSelected = currentTimeLength == value;
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      setState(() {
                        currentTimeLength = value;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? LinearGradient(
                                colors: [
                                  AppColors.primaryPurple,
                                  AppColors.primaryRed,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                        borderRadius: smallRadius,
                        color: AppColors.pageBackground,
                        boxShadow: !isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.white,
                                  blurRadius: buttonBlurRadius,
                                  offset: -buttonOffset,
                                  inset: true,
                                ),
                                BoxShadow(
                                  blurRadius: buttonBlurRadius,
                                  offset: buttonOffset,
                                  color: AppColors.bottomShadow,
                                  inset: true,
                                ),
                              ]
                            : [],
                      ),
                      child: Text(
                        value,
                        style:  TextStyle(
                            fontSize: 15,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: AppColors.regularText,
                          ),
                        ),
                      ),
                  );
                }).toList(),
              ),
            ],
          ),
          SizedBox(height: 8),
          SensorBarChart(data: weeklyData[currentData]),
        ],
      ),
    );
  }
}
