import 'package:farmulan/home/weather_property.dart';
import 'package:farmulan/utils/constants/colors.dart';
import 'package:farmulan/utils/constants/icons.dart';
import 'package:flutter/material.dart';

class WeatherWidget extends StatefulWidget {
  const WeatherWidget({super.key});

  @override
  State<WeatherWidget> createState() => _WeatherWidgetState();
}

class _WeatherWidgetState extends State<WeatherWidget> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width - 40;
    double height = MediaQuery.of(context).size.height / (844 / 200);
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 8),
            blurRadius: 24,
            spreadRadius: 0,
            color: AppColors.primary.withValues(alpha: 0.13),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.2),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              //   Cloud
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(AppIcons.sunny, size: 25),
                  SizedBox(width: width / 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'May 17, 2025 10:05 am',
                        style: TextStyle(
                            fontFamily: 'Zen Kaku Gothic Antique',
                            fontSize: 15,
                            fontWeight: FontWeight.normal,
                            color: AppColors.authPrimaryText,
                          ),

                      ),
                      Text(
                        'Cloudy',
                        style:  const TextStyle(
                            fontFamily: 'Zen Kaku Gothic Antique',
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.authPrimaryText,
                          ),
                        ),
                      Text(
                        'Kigali, Rwanda',
                        style:  const TextStyle(
                            fontFamily: 'Zen Kaku Gothic Antique',
                            fontSize: 15,
                            fontWeight: FontWeight.normal,
                            color: AppColors.authPrimaryText,
                          ),
                        ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    '23°c',
                    style:  const TextStyle(
                        fontFamily: 'Zen Kaku Gothic Antique',
                        fontSize: 28,
                        fontWeight: FontWeight.w500,
                        color: AppColors.authPrimaryText,
                      ),
                    ),
                ],
              ),
              const Divider(
                indent: 20,
                endIndent: 20,
                height: 25,
                thickness: 1,
                color: AppColors.authPrimaryText,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  WeatherProp(
                    icon: AppIcons.drop,
                    title: 'Humidity',
                    value: '97%',
                  ),
                  WeatherProp(
                    icon: AppIcons.eye,
                    title: 'Visibility',
                    value: '7km',
                  ),
                  WeatherProp(
                    icon: AppIcons.wind,
                    title: 'NE Wind',
                    value: '3km/h',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ForecastContainer extends StatelessWidget {
  const ForecastContainer({super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width - 40;
    double height = MediaQuery.of(context).size.height / (844 / 200);
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 2,
        ),
        gradient: LinearGradient(
          begin: Alignment(-1, -1),
          end: Alignment(1, 0),
          colors: [AppColors.primaryRed, AppColors.primaryPurple],
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
      child: Padding(
        padding: const EdgeInsets.all(16.2),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              //   Cloud
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(AppIcons.sunny, color: AppColors.mainBg, size: 35),
                  SizedBox(width: width / 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'May 16, 2023 10:05 am',
                        style:  const TextStyle(
                            fontFamily: 'Zen Kaku Gothic Antique',
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.mainBg,
                          ),

                      ),
                      Text(
                        'Cloudy',
                        style:  const TextStyle(
                            fontFamily: 'Zen Kaku Gothic Antique',
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.mainBg,
                          ),
                        ),
                      Text(
                        'Kigali, Rwanda',
                        style:  const TextStyle(
                            fontFamily: 'Zen Kaku Gothic Antique',
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.mainBg,
                          ),
                        ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    '23°c',
                    style:  const TextStyle(
                        fontFamily: 'Zen Kaku Gothic Antique',
                        fontSize: 28,
                        fontWeight: FontWeight.w500,
                        color: AppColors.mainBg,
                      ),
                    ),
                ],
              ),
              const Divider(
                indent: 20,
                endIndent: 20,
                height: 25,
                thickness: 1,
                color: AppColors.mainBg,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  WeatherProp(
                    icon: AppIcons.drop,
                    title: 'Humidity',
                    value: '97%',
                  ),
                  WeatherProp(
                    icon: AppIcons.eye,
                    title: 'Visibility',
                    value: '7km',
                  ),
                  WeatherProp(
                    icon: AppIcons.wind,
                    title: 'NE Wind',
                    value: '3km/h',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
