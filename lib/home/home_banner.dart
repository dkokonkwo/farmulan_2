import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
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
  final box = Hive.box('farmulanDB');
  String _farmId = '';
  String farmImage = '';
  String _userName = '';
  Uint8List? _farmImageBytes;

  @override
  void initState() {
    super.initState();
    _loadInitialFarmData(); // Renamed for clarity
  }

  Future<void> _loadInitialFarmData() async {
    // 1. Get farm ID/name
    final name = box.get('firstName') as String? ?? '';
    if (name.isNotEmpty) {
      print('name: $name');
      setState(() {
        _userName = name;
      });
    }

    final storedFarmId = await box.get('farmId');
    final firstName = await box.get('firstName') as String;
    print('first name : $firstName');
    if (storedFarmId is String && storedFarmId.isNotEmpty) {
      setState(() {
        _farmId = hashToNumber(storedFarmId).toString();
        _userName = firstName;
      });
    } else {
      setState(() {
        _farmId = '______';
      });
      return;
    }

    // 2. Get cached image bytes
    final cachedBytes = box.get('farmImageBytes') as Uint8List?;
    if (cachedBytes != null) {
      setState(() {
        _farmImageBytes = cachedBytes;
      });
    }

    // 3. Fetch user and farm details from Firestore
    final user = Auth().currentUser;
    if (user == null) {
      if (!mounted) return;
      showErrorToast(context, 'User not signed in');
      return;
    }

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data()!;
        // Set userName from Firestore, as it's the most authoritative source
        setState(() {
          _userName = userData['firstName'] as String? ?? '';
          // Optional: Cache firstName in Hive here if you want to
          // await box.put('firstName', _userName);
        });
      }

      final farmRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('farms')
          .doc(_farmId);

      final farmSnapshot = await farmRef.get();
      final farmData = farmSnapshot.data() ?? {};

      final imageUrl = (farmData['farmImage'] as String?) ?? '';

      // Only attempt to download if imageUrl is available and different from what's potentially cached (if you store URL in state)
      // Or if no bytes are cached
      if (imageUrl.isNotEmpty &&
          (_farmImageBytes == null || !box.containsKey('farmImageBytes'))) {
        // check if bytes are not already present or if we need to refresh
        final response = await http.get(Uri.parse(imageUrl));
        if (response.statusCode == 200) {
          final bytes = response.bodyBytes;
          await box.put('farmImageBytes', bytes);
          if (!mounted) return;
          setState(() {
            _farmImageBytes = bytes;
          });
        } else {
          if (!mounted) return;
          showErrorToast(
            context,
            'Failed to download image: ${response.statusCode}',
          );
        }
      }
    } on FirebaseException catch (e) {
      if (!mounted) return;
      showErrorToast(context, 'Firebase Error: ${e.message}');
    } on http.ClientException catch (e) {
      if (!mounted) return;
      showErrorToast(context, 'Network Error: ${e.message}');
    } catch (e) {
      if (!mounted) return;
      showErrorToast(context, 'An unexpected error occurred: $e');
    }
  }

  Future<void> _loadUserName() async {
    final user = Auth().currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _userName = data['firstName'] as String? ?? '';
        });
      }
    } catch (e) {
      if (!mounted) return;
      showErrorToast(context, 'Error loading profile: $e');
    }
  }

  int hashToNumber(String input, {int digits = 8}) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    final hex = digest.toString();

    // Convert first 8 hex characters to int
    final chunk = hex.substring(0, 8);
    final num = int.parse(chunk, radix: 16);

    // Reduce to desired digit count
    final mod = pow(10, digits).toInt();
    return num % mod;
  }

  void doSomething() {}

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width - 40;
    double height = MediaQuery.of(context).size.height / (844 / 200);
    // final box = Hive.box('farmulanDB');
    // final bytes = box.get('farmImageBytes') as Uint8List?;
    return Stack(
      clipBehavior: Clip.none,
      alignment: AlignmentDirectional.bottomCenter,
      children: [
        Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: _farmImageBytes != null
                  ? MemoryImage(_farmImageBytes!) // Use state variable
                  : AssetImage(
                      AppImages.farmImg,
                    ), // Fallback to asset directly if no bytes
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
                        "$_userName's Farm",
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
