import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:farmulan/farm/farm_tabs.dart';
import 'package:farmulan/farm/plants.dart';
import 'package:farmulan/farm/settings.dart';
import 'package:farmulan/utils/constants/images.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

import '../authentication/auth.dart';
import '../utils/constants/colors.dart';
import '../utils/constants/toasts.dart';

class TrapClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double borderRadius = 20.0;
    double w = size.width;
    double h = size.height;

    var path = Path();
    path.moveTo(0, borderRadius);
    path.lineTo(0, h - borderRadius);
    path.quadraticBezierTo(0, h, borderRadius, h);
    path.lineTo(w - borderRadius, h * 0.833);
    path.quadraticBezierTo(w, h * 0.833, w, (h * 0.833) - borderRadius);
    path.lineTo(w, borderRadius);
    path.quadraticBezierTo(w, 0, w - borderRadius, 0);
    path.lineTo(borderRadius, 0);
    path.quadraticBezierTo(0, 0, 0, borderRadius);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

class TabContainer extends StatefulWidget {
  // final TabController tabController;
  const TabContainer({super.key});

  @override
  State<TabContainer> createState() => _TabContainerState();
}

class _TabContainerState extends State<TabContainer> {
  List<bool> isSelected = [true, false, false];
  List<String> titles = ['PLANTS', 'LOGS', 'SETTINGS'];
  int selectedIndex = 0;

  void switchTabs(int index) {
    for (int i = 0; i < isSelected.length; i++) {
      setState(() {
        selectedIndex = index;
        for (int i = 0; i < isSelected.length; i++) {
          isSelected[i] = i == index;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width / 1.11;
    final height = 130.0;
    return Column(
      children: [
        ClipPath(
          clipper: TabTitleClipper(),
          child: SizedBox(
            width: width,
            height: height,
            child: Stack(
              children: [
                Positioned(
                  bottom: 20,
                  left: 10,
                  child: GestureDetector(
                    onTap: () => switchTabs(0),
                    child: FarmOptions(
                      isSelected: isSelected[0],
                      title: titles[0],
                    ),
                  ),
                ),
                Positioned(
                  right: width / 2 - 25,
                  bottom: 45,
                  child: GestureDetector(
                    onTap: () => switchTabs(1),
                    child: FarmOptions(
                      isSelected: isSelected[1],
                      title: titles[1],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 65,
                  right: 10,
                  child: GestureDetector(
                    onTap: () => switchTabs(2),
                    child: FarmOptions(
                      isSelected: isSelected[2],
                      title: titles[2],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          width: width,
          child: IndexedStack(
            index: selectedIndex,
            children: [PlantsTab(), Text('data 2'), SettingsTab()],
          ),
        ),
      ],
    );
  }
}

class TabTitleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double w = size.width;
    double h = size.height;
    double slope = 4 / 35;

    var path = Path();
    path.moveTo(0, slope * w);
    path.lineTo(0, h);
    path.lineTo(w, h - (w * slope));
    path.lineTo(w, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

class FarmHeroSection extends StatefulWidget {
  const FarmHeroSection({super.key});

  @override
  State<FarmHeroSection> createState() => _FarmHeroSectionState();
}

class _FarmHeroSectionState extends State<FarmHeroSection> {
  String firstName = '';
  String farmId = '';
  String farmImage = '';
  Uint8List? bytes;

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
  }

  Future<void> _loadUserDetails() async {
    final myBox = Hive.box('farmulanDB');
    firstName = myBox.get('firstName') as String? ?? '';
    final unHashedId = myBox.get('farmId') as String? ?? '';
    farmId = unHashedId.isNotEmpty ? hashToNumber(unHashedId).toString() : '';
    bytes = myBox.get('farmImageBytes') as Uint8List?;

    if (bytes != null || farmId.isEmpty) {
      if (mounted) setState(() {});
      if (farmId.isEmpty) {
        showInfoToast(context, 'Start your farm setup by adding your location');
      }
      return;
    }

    // no image stored locally check database
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
          .doc(farmId);

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
        return;
      }

      final imageBytes = response.bodyBytes;
      await myBox.put('farmImageBytes', imageBytes);

      if (!mounted) return;
      setState(() {
        farmImage = imageUrl; // store to a field
        bytes = imageBytes;
      });
    } catch (e) {
      if (!mounted) return;
      showErrorToast(context, 'Failed to fetch farm Image: $e');
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

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width / 1.11;
    return Container(
      width: width,
      height: width / 1.46,
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: ShapeDecoration(
        shape: const FarmHeroShape(usePadding: false),
        shadows: [
          BoxShadow(
            color: Color(0xff3B4056).withValues(alpha: 0.15),
            offset: Offset(0, 20),
            blurRadius: 40,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: width,
            height: width / 2.3,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(
                image: bytes != null
                    ? MemoryImage(bytes!)
                    : farmImage.isNotEmpty
                    ? NetworkImage(farmImage)
                    : AssetImage(AppImages.farmImg),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            "$firstName's Farm",
            style: TextStyle(
              fontFamily: 'Zen Kaku Gothic Antique',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          Text(
            "ID: $farmId",
            style: TextStyle(
              fontFamily: 'Zen Kaku Gothic Antique',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.regularText.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}

class FarmHeroShape extends ShapeBorder {
  final bool usePadding;
  const FarmHeroShape({this.usePadding = true});

  @override
  // TODO: implement dimensions
  EdgeInsetsGeometry get dimensions =>
      EdgeInsets.only(bottom: usePadding ? 20 : 0);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return getOuterPath(rect, textDirection: textDirection);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final r = rect;
    final h = r.height;
    final br = 20.0;
    final slopeY = h * 0.833;

    return Path()
      ..moveTo(r.left, r.top + br)
      ..lineTo(r.left, r.bottom - br)
      ..quadraticBezierTo(r.left, r.bottom, r.left + br, r.bottom)
      ..lineTo(r.right - br, r.top + slopeY)
      ..quadraticBezierTo(r.right, r.top + slopeY, r.right, r.top + slopeY - br)
      ..lineTo(r.right, r.top + br)
      ..quadraticBezierTo(r.right, r.top, r.right - br, r.top)
      ..lineTo(r.left + br, r.top)
      ..quadraticBezierTo(r.left, r.top, r.left, r.top + br)
      ..close();
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final paint = Paint()..color = Color(0xffF4F7FB);
    canvas.drawPath(getOuterPath(rect), paint);
  }

  @override
  ShapeBorder scale(double t) {
    // If you ever want to scale your border, return a new instance:
    return FarmHeroShape(usePadding: usePadding);
  }
}
