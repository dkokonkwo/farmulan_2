import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmulan/farm/plant_details.dart';
import 'package:farmulan/farm/plant_item.dart';
import 'package:farmulan/utils/constants/add_buttons.dart';
import 'package:farmulan/utils/constants/colors.dart';
import 'package:farmulan/utils/constants/icons.dart';
import 'package:farmulan/utils/constants/skeletons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:lottie/lottie.dart';

import '../authentication/auth.dart';
import '../utils/constants/toasts.dart';

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
                    child: Lottie.asset('assets/animations/growing.json'),
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
                            style: TextStyle(
                              fontFamily: 'Zen Kaku Gothic Antique',
                              fontSize: 15,
                              fontWeight: FontWeight.normal,
                              color: AppColors.mainBg,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        widget.name,
                        style: TextStyle(
                          fontFamily: 'Zen Kaku Gothic Antique',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ),
                      Text(
                        "Planted ${widget.timeOfPlant} days ago",
                        style: TextStyle(
                          fontFamily: 'Zen Kaku Gothic Antique',
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: AppColors.mainBg,
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
  List<PlantInfo> crops = [];
  final myBox = Hive.box('farmulanDB');
  bool _isLoadingInitialData = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadCrops().then((_) {
      // Once _loadCrops completes (successfully or with error), set loading to false
      if (mounted) {
        setState(() {
          _isLoadingInitialData = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCrops() async {
    final farmId = myBox.get('farmId') as String? ?? '';

    final user = Auth().currentUser;
    if (user == null || farmId.isEmpty) {
      showErrorToast(context, 'User not signed in or no farm selected');
      return;
    }

    try {
      final farmRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('farms')
          .doc(farmId);

      final snapshot = await farmRef.get();
      final data = snapshot.data() ?? {};

      final farmCrops = (data['crops'] as List<dynamic>? ?? [])
          .cast<Map<String, dynamic>>();
      setState(() {
        crops = List<PlantInfo>.generate(farmCrops.length, (i) {
          final m = farmCrops[i];
          //Try to get a Timestamp, else null
          final Timestamp? ts = m['timePlanted'] as Timestamp?;
          final DateTime plantedDate = ts?.toDate() ?? DateTime.now();
          final daysSince = DateTime.now().difference(plantedDate).inDays;
          return PlantInfo(
            farmCrops[i]['name'] as String,
            farmCrops[i]['isGrowing'] as bool,
            daysSince,
            farmCrops[i]['growthStage'] as int,
          );
        });
      });
    } catch (e) {
      if (!mounted) return;
      showErrorToast(context, 'Failed to fetch farm data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width / 1.11;
    double height = MediaQuery.of(context).size.width / 1.4;

    if (_isLoadingInitialData) {
      return Column(
        children: [
          SizedBox(
            height: height,
            width: width,
            child: Stack(
              children: [
                // Left crop
                Positioned(top: 25, left: 0, child: PlantBoxSkeleton()),
                Positioned(top: 0, right: 0, child: PlantBoxSkeleton()),
              ],
            ),
          ),
        ],
      );
      // Or: CircularProgressIndicator() while you’re loading for the first time
    }

    return ValueListenableBuilder<Box<dynamic>>(
      valueListenable: myBox.listenable(keys: ['crops']),
      builder: (context, Box b, _) {
        // safely read & convert to raw list
        final rawDynamic = b.get('crops') as List<dynamic>? ?? [];
        final farmCrops = rawDynamic
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();

        if (farmCrops.isEmpty) {
          return Column(
            children: [
              SizedBox(
                height: height,
                width: width,
                child: Stack(
                  children: [
                    // Left crop
                    Positioned(top: 25, left: 0, child: PlantBoxSkeleton()),
                    Positioned(top: 0, right: 0, child: PlantBoxSkeleton()),
                    AddCropButton(),
                  ],
                ),
              ),
            ],
          );
        }

        // Map into PlantInfo models
        final freshCrops = List<PlantInfo>.generate(farmCrops.length, (i) {
          final m = farmCrops[i];
          final rawPlanted = m['timePlanted'];
          DateTime plantedDate;
          if (rawPlanted is Timestamp) {
            plantedDate = rawPlanted.toDate();
          } else if (rawPlanted is DateTime) {
            plantedDate = rawPlanted;
          } else {
            plantedDate = DateTime.now();
          }
          final daysSince = DateTime.now().difference(plantedDate).inDays;
          return PlantInfo(
            m['name'] as String,
            m['isGrowing'] as bool,
            daysSince,
            m['growthStage'] as int,
          );
        });

        // Build grid using freshCrops…
        final cropCount = freshCrops.length;
        final numRows = (cropCount / 2).ceil();

        return Column(
          children: [
            for (var row = 0; row < numRows; row++)
              SizedBox(
                height: height,
                width: width,
                child: Stack(
                  children: [
                    // Left crop
                    Positioned(
                      top: 25,
                      left: 0,
                      child: GestureDetector(
                        onTap: () => Get.to(PlantDetails(index: row * 2)),
                        child: PlantItem(plantInfo: crops[row * 2]),
                      ),
                    ),
                    // Right crop (only if exists)
                    if ((row * 2 + 1) < cropCount)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () => Get.to(PlantDetails(index: row * 2 + 1)),
                          child: PlantItem(plantInfo: crops[row * 2 + 1]),
                        ),
                      ),
                  ],
                ),
              ),
            // Always show option to add button
            AddCropButton(),
          ],
        );
      },
    );
  }
}

class PlantInfo {
  PlantInfo(this.name, this.isGrowing, this.timeOfPlant, this.plantStage);

  String name;
  bool isGrowing;
  int timeOfPlant;
  int plantStage;
}
