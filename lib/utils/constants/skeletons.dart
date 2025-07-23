import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../farm/plant_item.dart';
import 'colors.dart';

class PlantBoxSkeleton extends StatefulWidget {
  const PlantBoxSkeleton({super.key});

  @override
  State<PlantBoxSkeleton> createState() => _PlantBoxSkeletonState();
}

class _PlantBoxSkeletonState extends State<PlantBoxSkeleton> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width / 2.36;
    double blur = 20.0;
    Offset distance = Offset(10, 10);
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      period: Duration(milliseconds: 800),
      child: Container(
        width: width,
        height: width * 1.46,
        decoration: ShapeDecoration(
          shape: const PlantItemShape(usePadding: false),
          shadows: [
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
      ),
    );
  }
}
