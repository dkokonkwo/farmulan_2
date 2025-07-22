import 'package:farmulan/utils/constants/colors.dart';
import 'package:flutter/material.dart';

class GlassContainer extends StatelessWidget {
  final double width;
  final double height;
  final Widget child;
  GlassContainer({
    super.key,
    required this.width,
    required this.child,
    required this.height,
  });

  final _borderRadius = BorderRadius.circular(12);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: _borderRadius,
        color: AppColors.white,
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
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
        child: child,
      ),
    );
  }
}

class SingleData extends StatefulWidget {
  final IconData icon;
  final String title;
  String value;
  SingleData({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  State<SingleData> createState() => _SingleDataState();
}

class _SingleDataState extends State<SingleData> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [AppColors.primaryPurple, AppColors.primaryRed],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          blendMode: BlendMode.srcIn,
          child: Icon(widget.icon, size: 20),
        ),
        Text(
          widget.title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppColors.regularText.withValues(alpha: 0.5),
          ),
        ),

        Text(
          widget.value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

class MultipleData extends StatefulWidget {
  final String title;
  final List<IconData> icons;
  List<String> data;
  MultipleData({
    super.key,
    required this.title,
    required this.icons,
    required this.data,
  });

  @override
  State<MultipleData> createState() => _MultipleDataState();
}

class _MultipleDataState extends State<MultipleData> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(
          widget.title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.regularText.withValues(alpha: 0.5),
          ),
        ),

        Row(
          children: [
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [AppColors.primaryPurple, AppColors.primaryRed],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
              blendMode: BlendMode.srcIn,
              child: Icon(widget.icons[0], size: 20),
            ),
            SizedBox(width: 10),
            Row(
              spacing: 12,
              children: [
                Text(
                  'Last',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.regularText.withValues(alpha: 0.5),
                  ),
                ),

                Text(
                  widget.data[0],
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ],
        ),
        Row(
          children: [
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [AppColors.primaryPurple, AppColors.primaryRed],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
              blendMode: BlendMode.srcIn,
              child: Icon(widget.icons[1], size: 20),
            ),
            SizedBox(width: 10),
            Row(
              spacing: 12,
              children: [
                Text(
                  'Next',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.regularText.withValues(alpha: 0.5),
                  ),
                ),

                Text(
                  widget.data[1],
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
