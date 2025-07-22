import 'package:farmulan/utils/constants/colors.dart';
import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';

class CustomFarmTab extends StatefulWidget {
  final bool isSelected;
  final String title;
  const CustomFarmTab({
    super.key,
    required this.isSelected,
    required this.title,
  });

  @override
  State<CustomFarmTab> createState() => _CustomFarmTabState();
}

class _CustomFarmTabState extends State<CustomFarmTab> {
  @override
  Widget build(BuildContext context) {
    Offset distance = Offset(2, 2);
    double blur = 8;
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: widget.isSelected
            ? AppColors.mainBg.withValues(alpha: 0.9)
            : null,
        gradient: !widget.isSelected
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.secondary.withValues(alpha: 0.8),
                  AppColors.primary.withValues(alpha: 0.8),
                ],
              )
            : null,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: widget.isSelected
              ? AppColors.primary.withValues(alpha: 0.3)
              : AppColors.mainBg.withValues(alpha: 0.3),
        ),
        boxShadow: widget.isSelected
            ? [
                BoxShadow(
                  color: Color(0xff38445A).withValues(alpha: 0.6),
                  blurRadius: blur,
                  offset: -distance,
                ),
                BoxShadow(
                  blurRadius: blur,
                  offset: distance,
                  color: Color(0xff252B39).withValues(alpha: 0.6),
                ),
              ]
            : [],
      ),
      child: Text(
        widget.title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: widget.isSelected ? AppColors.primary : AppColors.mainBg,
        ),
      ),
    );
  }
}

class FarmOptions extends StatefulWidget {
  bool isSelected;
  final String title;
  FarmOptions({super.key, required this.title, required this.isSelected});

  @override
  State<FarmOptions> createState() => _FarmOptionsState();
}

class _FarmOptionsState extends State<FarmOptions> {
  @override
  Widget build(BuildContext context) {
    const bgColor = AppColors.pageBackground;
    const offset = Offset(4, 4);
    const blur = 8.0;
    final radius = BorderRadius.circular(10);
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: radius,
        color: bgColor,
        boxShadow: [
          BoxShadow(
            color: AppColors.topShadow,
            blurRadius: blur,
            offset: -offset,
            inset: !widget.isSelected,
          ),
          BoxShadow(
            color: AppColors.bottomShadow,
            blurRadius: blur,
            offset: offset,
            inset: !widget.isSelected,
          ),
        ],
      ),
      child: Text(
        widget.title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: widget.isSelected
              ? AppColors.primary
              : AppColors.regularText.withValues(alpha: 0.6),
        ),
      ),
    );
  }
}
