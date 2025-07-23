import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmulan/utils/constants/icons.dart';
import 'package:farmulan/utils/constants/images.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

import '../authentication/auth.dart';
import '../utils/constants/colors.dart';
import '../utils/constants/toasts.dart';

class HomeBanner extends StatefulWidget {
  const HomeBanner({super.key});

  @override
  State<HomeBanner> createState() => _HomeBannerState();
}

class _HomeBannerState extends State<HomeBanner> {
  String _farmId = '';
  String farmImage = '';

  @override
  void initState() {
    super.initState();
    _getFarmDetails();
  }

  Future<void> _getFarmDetails() async {
    final box = Hive.box('farmulanDB');
    final stored = box.get('farmId');
    if (stored is String && stored.isNotEmpty) {
      setState(() {
        _farmId = stored;
      });
    } else {
      // Optional: show a placeholder or prompt the user to create a farm
      setState(() {
        _farmId = '______';
      });
      if (!mounted) return;
      showInfoToast(context, 'Start your farm setup by adding your location');
      return;
    }

    final user = Auth().currentUser;
    if (user == null) {
      showErrorToast(context, 'User not signed in');
      return;
    }

    try {
      final farmRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('farms')
          .doc(_farmId);

      final snapshot = await farmRef.get();
      final data = snapshot.data() ?? {};

      // pull image from firestore
      final imageUrl = (data['farmImage'] as String?) ?? '';
      if (imageUrl.isEmpty) {
        return;
      }

      // download image bytes
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode != 200) {
        if (!mounted) return;
        showErrorToast(
          context,
          'Failed to download image: ${response.statusCode}',
        );
        // throw Exception('Failed to download image: ${response.statusCode}');
      }

      final bytes = response.bodyBytes;

      // Store the raw bytes in Hive
      await box.put('farmImageBytes', bytes);

      if (!mounted) return;
      setState(() {
        farmImage = imageUrl; // store to a field if you want immediate use
      });
    } catch (e) {
      if (!mounted) return;
      showErrorToast(context, 'Failed to fetch farm Image: $e');
    }
  }

  void doSomething() {}

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width - 40;
    double height = MediaQuery.of(context).size.height / (844 / 200);
    final box = Hive.box('farmulanDB');
    final bytes = box.get('farmImageBytes') as Uint8List?;
    return Stack(
      clipBehavior: Clip.none,
      alignment: AlignmentDirectional.bottomCenter,
      children: [
        Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: bytes != null
                  ? MemoryImage(bytes)
                  : farmImage.isNotEmpty
                  ? NetworkImage(farmImage)
                  : AssetImage(AppImages.farmImg),
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
                        style: const TextStyle(
                          fontFamily: 'Zen Kaku Gothic Antique',
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),

                      Text(
                        "ID: $_farmId",
                        style: const TextStyle(
                          fontFamily: 'Zen Kaku Gothic Antique',
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                          color: AppColors.secondary,
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
