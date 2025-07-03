import 'dart:ui';

import 'package:farmulan_2/utils/constants/colors.dart';
import 'package:farmulan_2/utils/constants/images.dart';
import 'package:flutter/material.dart';

class GlassBox extends StatelessWidget {
  final double height;
  final double width;
  final Widget child;
  const GlassBox({
    super.key,
    required this.height,
    required this.width,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage(AppImages.background)),
        ),
        width: width,
        height: height,
        child: Stack(
          children: [
            // blur Effect
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(),
            ),

            //   gradient effect
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.subheadingText.withValues(alpha: 0.1),
                    AppColors.primary.withValues(alpha: 0.1),
                  ],
                ),
              ),
            ),
            child,
          ],
        ),
      ),
    );
  }
}
