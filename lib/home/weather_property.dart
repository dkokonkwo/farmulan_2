import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/constants/colors.dart';

class WeatherProp extends StatefulWidget {
  final IconData icon;
  final String title;
  String value;
  WeatherProp({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  State<WeatherProp> createState() => _WeatherPropState();
}

class _WeatherPropState extends State<WeatherProp> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, size: 18, color: AppColors.mainBg),
              const SizedBox(width: 5),
              Text(
                widget.value,
                style: GoogleFonts.zenKakuGothicAntique(
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ),

          Text(
            widget.title,
            style: GoogleFonts.zenKakuGothicAntique(
              textStyle: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: AppColors.mainBg.withValues(alpha: 0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
