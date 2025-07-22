import 'package:farmulan/farm/modal_tab.dart';
import 'package:farmulan/farm/plant_container.dart';
import 'package:farmulan/utils/constants/glass_box.dart';
import 'package:farmulan/utils/constants/icons.dart';
import 'package:flutter/material.dart';

import '../utils/constants/colors.dart';

void showMyBottomSheet(
  BuildContext context,
  TabController tabController,
  String plantName,
  String plantImgUrl,
) {
  double height = MediaQuery.of(context).size.height;
  double width = MediaQuery.of(context).size.width;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    sheetAnimationStyle: const AnimationStyle(
      duration: Duration(milliseconds: 0),
      reverseDuration: Duration(milliseconds: 300),
    ),
    builder: (context) => GlassBox(
      height: height,
      width: width,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.mainBg.withValues(alpha: 0.5),
                            AppColors.secondary,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            offset: const Offset(0, 8),
                            blurRadius: 24,
                            spreadRadius: 0,
                            color: Colors.black.withValues(alpha: 0.3),
                          ),
                        ],
                      ),
                      child: Icon(
                        AppIcons.downArrow,
                        color: AppColors.white,
                        size: 30,
                      ),
                    ),
                  ),
                  SizedBox(width: 60),
                  Text(
                    plantName,
                    style: const TextStyle(
                      fontFamily: 'Zen Kaku Gothic Antique',
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.mainBg,
                    ),
                  ),
                ],
              ),
            ),
            PlantModalContainer(imgUrl: plantImgUrl),
            Container(
              height: height / 2,
              width: width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                gradient: LinearGradient(
                  colors: [AppColors.secondary, AppColors.primary],
                  begin: Alignment(-1, -1),
                  end: Alignment(0.8, 1),
                ),
              ),
              child: Column(
                children: [
                  SizedBox(height: 8),
                  Container(
                    height: 5,
                    width: width / 4.8,
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  SizedBox(height: 20),
                  ModalTabContainer(),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
