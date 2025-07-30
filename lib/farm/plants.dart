import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmulan/farm/plant_details.dart';
import 'package:farmulan/farm/plant_item.dart';
import 'package:farmulan/utils/constants/add_buttons.dart';
import 'package:farmulan/utils/constants/colors.dart';
import 'package:farmulan/utils/constants/icons.dart';
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
                  SizedBox(
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
  bool _isLoadingInitialData = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    setState(() {
      _isLoadingInitialData = true;
    });
    loadCrops().then((_) {
      // Once _loadCrops completes (successfully or with error), set loading to false
      setState(() {
        _isLoadingInitialData = false;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> ensureFarmIdInHive() async {
    final box = Hive.box('farmulanDB');
    String? farmId = box.get('farmId') as String?;
    if (farmId != null && farmId.isNotEmpty) return;

    final user = Auth().currentUser;
    if (user == null) {
      // not signed in yet
      return;
    }

    // fetch the first farm document under this user
    final querySnap = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('farms')
        .limit(1)
        .get();

    if (querySnap.docs.isEmpty) {
      // user has no farms
      return;
    }

    farmId = querySnap.docs.first.id;
    await box.put('farmId', farmId);
  }

  Future<void> loadCrops() async {
    final box = Hive.box('farmulanDB');
    final farmId = box.get('farmId') as String?;
    final user = Auth().currentUser;
    if (farmId == null) {
      await ensureFarmIdInHive();
    }
    if (user == null || farmId == null || farmId.isEmpty) {
      showErrorToast(context, 'User not signed in or no farm selected');
      return;
    }

    try {
      // 1️⃣ Firestore attempt
      final col = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('farms')
          .doc(farmId)
          .collection('crops');

      final snap = await col.get();

      // convert each doc → map + PlantInfo
      final freshHiveList = <Map<String, dynamic>>[];
      final freshInfos = <PlantInfo>[];

      for (final doc in snap.docs) {
        final m = doc.data();
        final cropId = doc.id;
        final name = m['name'] as String? ?? '';
        final isGrowing = m['isGrowing'] as bool? ?? false;
        final growthStage = m['growthStage'] as int? ?? 0;

        // Firestore stores timePlanted as DateTime (v2) or Timestamp (v1)
        DateTime plantedDate;
        final raw = m['timePlanted'];
        if (raw is DateTime) {
          plantedDate = raw;
        } else if (raw is Timestamp) {
          plantedDate = raw.toDate();
        } else {
          plantedDate = DateTime.now();
        }
        final daysSince = DateTime.now().difference(plantedDate).inDays;

        // collect for UI
        freshInfos.add(
          PlantInfo(name, isGrowing, daysSince, growthStage, cropId),
        );

        // collect for Hive (store millis since epoch)
        freshHiveList.add({
          'cropId': cropId,
          'name': name,
          'isGrowing': isGrowing,
          'growthStage': growthStage,
          'timePlanted': plantedDate.millisecondsSinceEpoch,
        });
      }

      // write into Hive for offline
      await box.put('crops', freshHiveList);
      await box.put('numOfCrops', freshHiveList.length);

      // update UI
      setState(() {
        crops = freshInfos;
        _isLoadingInitialData = false;
      });
    } catch (e) {
      // 🔄 fallback to Hive
      final rawList =
          box.get('crops', defaultValue: <Map<String, dynamic>>[]) as List;
      final infos = <PlantInfo>[];
      for (final e in rawList) {
        final m = Map<String, dynamic>.from(e as Map);
        final name = m['name'] as String? ?? '';
        final isGrowing = m['isGrowing'] as bool? ?? false;
        final growthStage = m['growthStage'] as int? ?? 0;
        final cropId = m['cropId'] as String? ?? '';

        final millis = m['timePlanted'] as int?;
        final plantedDate = millis != null
            ? DateTime.fromMillisecondsSinceEpoch(millis)
            : DateTime.now();
        final daysSince = DateTime.now().difference(plantedDate).inDays;

        infos.add(PlantInfo(name, isGrowing, daysSince, growthStage, cropId));
      }

      if (!mounted) return;
      showErrorToast(context, 'Offline: loaded crops from local storage.');
      setState(() {
        crops = infos;
        _isLoadingInitialData = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width / 1.11;
    double height = MediaQuery.of(context).size.width / 1.4;
    final farmId = myBox.get('farmId') as String? ?? '';

    if (_isLoadingInitialData) {
      return SizedBox(
        height: height,
        width: width,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (farmId.isEmpty) {
      return Column(
        children: [
          SizedBox(
            height: height,
            width: width,
            child: Center(
              child:
                  // Left crop
                  AddCropButton(onCropAdded: loadCrops),
            ),
          ),
        ],
      );
      // Or: CircularProgressIndicator() while you’re loading for the first time
    }

    return ValueListenableBuilder<Box<dynamic>>(
      valueListenable: myBox.listenable(keys: ['numOfCrops']),
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
                    // Positioned(top: 25, left: 0, child: PlantBoxSkeleton()),
                    // Positioned(top: 0, right: 0, child: PlantBoxSkeleton()),
                    AddCropButton(onCropAdded: loadCrops),
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
            m['cropId'] as String,
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
                        onTap: () => Get.to(PlantDetails(data: crops[row * 2])),
                        child: PlantItem(plantInfo: crops[row * 2]),
                      ),
                    ),
                    // Right crop (only if exists)
                    if ((row * 2 + 1) < cropCount)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () =>
                              Get.to(PlantDetails(data: crops[row * 2 + 1])),
                          child: PlantItem(plantInfo: crops[row * 2 + 1]),
                        ),
                      ),
                  ],
                ),
              ),
            // Always show option to add button
            AddCropButton(onCropAdded: loadCrops),
          ],
        );
      },
    );
  }
}

class PlantInfo {
  PlantInfo(
    this.name,
    this.isGrowing,
    this.timeOfPlant,
    this.plantStage,
    this.cropId,
  );

  final String name;
  final bool isGrowing;
  final int timeOfPlant;
  final int plantStage;
  final String cropId;
}
