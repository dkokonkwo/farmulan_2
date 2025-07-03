import 'package:farmulan_2/home/weather_property.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/constants/colors.dart';
import '../utils/constants/icons.dart';

class WeatherInfo extends StatefulWidget {
  const WeatherInfo({super.key});

  @override
  State<WeatherInfo> createState() => _WeatherInfoState();
}

class _WeatherInfoState extends State<WeatherInfo> {
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
                    'Kigali',
                    style: GoogleFonts.zenKakuGothicAntique(
                      textStyle: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: AppColors.mainBg,
                      ),
                    ),
                  ),
                  Text(
                    'Rwanda',
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
                    value: '97%',
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(AppIcons.sunny, color: AppColors.mainBg, size: 20),
                  SizedBox(width: 10),
                  Text(
                    'Partly Cloudy',
                    style: GoogleFonts.zenKakuGothicAntique(
                      textStyle: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.normal,
                        color: AppColors.mainBg.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                '-10°c',
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
