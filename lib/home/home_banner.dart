import 'package:farmulan_2/utils/constants/icons.dart';
import 'package:farmulan_2/utils/constants/images.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/constants/colors.dart';

class HomeBanner extends StatelessWidget {
  const HomeBanner({super.key});

  void doSomething() {}

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width - 40;
    double height = MediaQuery.of(context).size.height / (844 / 200);
    return Stack(
      clipBehavior: Clip.none,
      alignment: AlignmentDirectional.bottomCenter,
      children: [
        Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            image: const DecorationImage(
              image: AssetImage(AppImages.farmImg),
              fit: BoxFit.cover,
            ),
            color: AppColors.mainBg,
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        Positioned(
          bottom: -25,
          child: Container(
            width: width - 65,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
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
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Charlie's Farm",
                        style: GoogleFonts.zenKakuGothicAntique(
                          textStyle: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),

                      Text(
                        "ID: 1344295024",
                        style: GoogleFonts.zenKakuGothicAntique(
                          textStyle: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.normal,
                            color: AppColors.secondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.secondary.withValues(
                        alpha: 0.1,
                      ),
                    ),
                    onPressed: doSomething,
                    icon: Icon(AppIcons.rightArrow, weight: 40, size: 18),
                    color: AppColors.primary,
                    focusColor: AppColors.primary.withValues(alpha: 0.13),
                    hoverColor: AppColors.primary.withValues(alpha: 0.13),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
