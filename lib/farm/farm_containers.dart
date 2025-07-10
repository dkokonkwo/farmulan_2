import 'dart:ui';

import 'package:farmulan/farm/farm_tabs.dart';
import 'package:farmulan/farm/plants.dart';
import 'package:farmulan/utils/constants/images.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/constants/colors.dart';

class TopContainer extends StatelessWidget {
  const TopContainer({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width / 1.11;
    final borderRadius = BorderRadius.circular(20);
    return ClipPath(
      clipper: TrapClipper(),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: width,
          height: width / 1.46,
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
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: width,
                  height: width / 2.3,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                      image: AssetImage(AppImages.farmImg),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Charlie's Farm",
                  style: GoogleFonts.zenKakuGothicAntique(
                    textStyle: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ),
                ),
                Text(
                  "ID: 1344295024",
                  style: GoogleFonts.zenKakuGothicAntique(
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.mainBg,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

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
            children: [PlantsTab(), Text('data 2'), Text('data 3')],
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

class FarmHeroSection extends StatelessWidget {
  const FarmHeroSection({super.key});

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
                image: AssetImage(AppImages.farmImg),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 2),
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
              textStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.regularText.withValues(alpha: 0.5),
              ),
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
