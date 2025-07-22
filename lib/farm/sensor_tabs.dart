import 'package:flutter/material.dart';

import '../utils/constants/colors.dart';

class SensorTab extends StatefulWidget {
  final IconData icon;
  final String title;
  String value;
  SensorTab({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  State<SensorTab> createState() => _SensorTabState();
}

class _SensorTabState extends State<SensorTab> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width / (390 / 144);
    return Container(
      width: width,
      height: (164 / 144) * width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: Color(0xffF4F7FB),
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
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryRed.withValues(alpha: 0.4),
            ),
            child: Center(
              child: Icon(
                widget.icon,
                color: AppColors.primaryPurple.withValues(alpha: 0.7),
                size: 25,
              ),
            ),
          ),
          Text(
            widget.title,
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.regularText.withValues(alpha: 0.5),
              ),
            ),
          Text(
            widget.value,
            style:  TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.regularText.withValues(alpha: 0.7),
              ),
            ),
        ],
      ),
    );
  }
}
