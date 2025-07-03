import 'dart:ui';

import 'package:flutter/material.dart';

import '../utils/constants/colors.dart';
import 'farm_containers.dart';

class PlantModalContainer extends StatefulWidget {
  String imgUrl;
  PlantModalContainer({super.key, required this.imgUrl});

  @override
  State<PlantModalContainer> createState() => _PlantModalContainerState();
}

class _PlantModalContainerState extends State<PlantModalContainer> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width / 1.11;
    final borderRadius = BorderRadius.circular(20);
    return ClipPath(
      clipper: TrapClipper(),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: width,
          height: width / 1.46,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.secondary.withValues(alpha: 0.6),
                AppColors.primary.withValues(alpha: 0.6),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: borderRadius,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 24,
                spreadRadius: 0,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 2,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Column(
              children: [
                Container(
                  width: width / 1.8,
                  height: width / 1.8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                      image: AssetImage(widget.imgUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
