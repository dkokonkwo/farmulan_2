import 'dart:ui';

import 'package:farmulan/farm/plant_data.dart';
import 'package:farmulan/farm/plant_details.dart';
import 'package:farmulan/farm/plant_item.dart';
import 'package:farmulan/utils/constants/colors.dart';
import 'package:farmulan/utils/constants/icons.dart';
import 'package:farmulan/utils/constants/images.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class PlantContainerClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double borderRadius = 20.0;
    double w = size.width;
    double h = size.height;
    double slope = 4 / 35;

    var path = Path();
    path.moveTo(0, slope * w);
    path.lineTo(0, h - borderRadius);
    path.quadraticBezierTo(0, h, borderRadius, h);
    path.lineTo(w - borderRadius, h - (w * slope));
    path.quadraticBezierTo(
      w,
      h - (w * slope),
      w,
      h - (w * slope) - borderRadius,
    );
    path.lineTo(w, borderRadius);
    path.quadraticBezierTo(w, 0, w - borderRadius, 0);
    path.lineTo(borderRadius, slope * w);
    path.quadraticBezierTo(0, slope * w, 0, slope * w + borderRadius);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

class CustomPlantContainer extends StatefulWidget {
  final String name;
  final bool isGrowing;
  final String imgUrl;
  final int timeOfPlant;
  const CustomPlantContainer({
    super.key,
    required this.name,
    required this.isGrowing,
    required this.imgUrl,
    required this.timeOfPlant,
  });

  @override
  State<CustomPlantContainer> createState() => _CustomPlantContainerState();
}

class _CustomPlantContainerState extends State<CustomPlantContainer> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width / 2.36;
    final borderRadius = BorderRadius.circular(20);
    return ClipPath(
      clipper: PlantContainerClipper(),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: width,
          height: width * 1.46,
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
            padding: EdgeInsets.all(8),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 3, vertical: 5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    width: width / 1.8,
                    height: width / 1.8,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(widget.imgUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(AppIcons.leaf, color: AppColors.white, size: 20),
                          SizedBox(width: 5),
                          Text(
                            widget.isGrowing ? "Growing" : "Not planted",
                            style: GoogleFonts.zenKakuGothicAntique(
                              textStyle: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.normal,
                                color: AppColors.mainBg,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        widget.name,
                        style: GoogleFonts.zenKakuGothicAntique(
                          textStyle: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                      Text(
                        "Planted ${widget.timeOfPlant} days ago",
                        style: GoogleFonts.zenKakuGothicAntique(
                          textStyle: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                            color: AppColors.mainBg,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PlantsTab extends StatefulWidget {
  const PlantsTab({super.key});

  @override
  State<PlantsTab> createState() => _PlantsTabState();
}

class _PlantsTabState extends State<PlantsTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width / 1.11;
    double height = MediaQuery.of(context).size.width / 1.4;

    List<PlantInfo> addedPlants = [
      PlantInfo("Tomatoes", true, AppImages.tomatoes, 8),
      PlantInfo("Lettuce", true, AppImages.lettuce, 8),
    ];
    return Column(
      children: [
        SizedBox(
          height: height,
          width: width,
          child: Stack(
            children: [
              Positioned(
                top: 25,
                left: 0,
                child: GestureDetector(
                  onTap: () {
                    Get.to(PlantDetails(index: 0));
                  },
                  child: PlantItem(
                    plantInfo: plantAppBarData[0],
                    imgUrl: addedPlants[0].imgUrl,
                  ),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () {
                    Get.to(PlantDetails(index: 1));
                  },
                  child: PlantItem(
                    plantInfo: plantAppBarData[1],
                    imgUrl: addedPlants[1].imgUrl,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: height,
          width: width,
          child: Stack(
            children: [
              Positioned(
                top: 25,
                left: 0,
                child: GestureDetector(
                  onTap: () {
                    Get.to(PlantDetails(index: 2));
                  },
                  child: PlantItem(
                    plantInfo: plantAppBarData[2],
                    imgUrl: addedPlants[0].imgUrl,
                  ),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () {
                    Get.to(PlantDetails(index: 3));
                  },
                  child: PlantItem(
                    plantInfo: plantAppBarData[1],
                    imgUrl: addedPlants[1].imgUrl,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class PlantInfo {
  PlantInfo(this.name, this.isGrowing, this.imgUrl, this.timeOfPlant);

  String name;
  bool isGrowing;
  String imgUrl;
  int timeOfPlant;
}
