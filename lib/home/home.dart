import 'package:farmulan_2/home/forecast_container.dart';
import 'package:farmulan_2/home/home_carousel.dart';
import 'package:farmulan_2/home/sensor_item.dart';
import 'package:farmulan_2/utils/constants/glass_container.dart';
import 'package:farmulan_2/utils/constants/icons.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    double smallWidth = MediaQuery.of(context).size.width / 3.42;
    double bigWidth = MediaQuery.of(context).size.width / 1.65;
    List<SingleData> containerData = [
      SingleData(
        icon: AppIcons.connection,
        title: 'Connectivity',
        value: 'Online',
      ),
      SingleData(icon: AppIcons.drop, title: 'Water Level', value: '85%'),
      SingleData(
        icon: AppIcons.temperature,
        title: 'Temperature',
        value: '23°c',
      ),
      SingleData(icon: AppIcons.wind, title: 'Humidity', value: '74%'),
      SingleData(
        icon: AppIcons.bulb,
        title: 'Light Intensity',
        value: 'Online',
      ),
    ];

    List<MultipleData> multContainerData = [
      MultipleData(
        icons: [AppIcons.calendar, AppIcons.timer],
        title: "Irrigation Status",
        data: ["6:30am", "5:00pm"],
      ),
    ];
    return SingleChildScrollView(
      child: Center(
        child: Column(
          children: [
            SizedBox(height: 10),
            WeatherInfo(),
            SizedBox(height: 20),
            HomeCarousel(),
            SizedBox(height: 25),
            Wrap(
              spacing: 8.0,
              runSpacing: 15.0,
              children: [
                SensorItem(
                  width: smallWidth,
                  height: smallWidth,
                  child: containerData[0],
                ),
                SensorItem(
                  width: bigWidth,
                  height: smallWidth,
                  child: multContainerData[0],
                ),
                SensorItem(
                  width: smallWidth,
                  height: smallWidth,
                  child: containerData[1],
                ),
                SensorItem(
                  width: smallWidth,
                  height: smallWidth,
                  child: containerData[2],
                ),
                SensorItem(
                  width: smallWidth,
                  height: smallWidth,
                  child: containerData[3],
                ),
                SensorItem(
                  width: smallWidth,
                  height: smallWidth,
                  child: containerData[4],
                ),
              ],
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
