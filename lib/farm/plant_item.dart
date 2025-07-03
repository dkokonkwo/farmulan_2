import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/constants/colors.dart';
import '../utils/constants/icons.dart';

class PlantItem extends StatefulWidget {
  final List<String> plantInfo;
  final String imgUrl;
  const PlantItem({super.key, required this.plantInfo, required this.imgUrl});

  @override
  State<PlantItem> createState() => _PlantItemState();
}

class _PlantItemState extends State<PlantItem> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width / 2.36;
    double blur = 20.0;
    Offset distance = Offset(10, 10);
    return Container(
      width: width,
      height: width * 1.46,
      decoration: ShapeDecoration(
        shape: const PlantItemShape(usePadding: false),
        shadows: [
          BoxShadow(
            color: AppColors.white,
            blurRadius: blur,
            offset: -distance,
          ),
          BoxShadow(
            blurRadius: blur,
            offset: distance,
            color: AppColors.bottomShadow,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(11, 13, 11, 13),
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
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [AppColors.primaryPurple, AppColors.primaryRed],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds),
                      blendMode: BlendMode.srcIn,
                      child: Icon(AppIcons.leaf, size: 20),
                    ),
                    SizedBox(width: 5),
                    Text(
                      widget.plantInfo[3],
                      style: GoogleFonts.zenKakuGothicAntique(
                        textStyle: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                          color: AppColors.regularText.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  widget.plantInfo[0],
                  style: GoogleFonts.zenKakuGothicAntique(
                    textStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.regularText.withValues(alpha: 0.7),
                    ),
                  ),
                ),
                Text(
                  "Planted ${widget.plantInfo[1]} days ago",
                  style: GoogleFonts.zenKakuGothicAntique(
                    textStyle: TextStyle(
                      fontSize: 13,
                      color: AppColors.regularText.withValues(alpha: 0.5),
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class PlantItemShape extends ShapeBorder {
  final bool usePadding;
  const PlantItemShape({this.usePadding = true});

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
    // Shrink the rect's bottom by 20 if usePadding
    final shrink = usePadding ? 20.0 : 0.0;
    final r = Rect.fromLTWH(
      rect.left,
      rect.top,
      rect.width,
      rect.height - shrink,
    );
    final w = r.width;
    final br = 20.0; // corner radius
    final slope = 4 / 35 * w; // adjust your slope-to-width calculation

    return Path()
      ..moveTo(r.left, slope)
      ..lineTo(r.left, r.bottom - br)
      ..quadraticBezierTo(r.left, r.bottom, r.left + br, r.bottom)
      ..lineTo(r.right - br, r.bottom - slope)
      ..quadraticBezierTo(
        r.right,
        r.bottom - slope,
        r.right,
        r.bottom - slope - br,
      )
      ..lineTo(r.right, r.top + br)
      ..quadraticBezierTo(r.right, r.top, r.right - br, r.top)
      ..lineTo(r.left + br, r.top + slope)
      ..quadraticBezierTo(r.left, r.top + slope, r.left, r.top + slope + br)
      ..close();
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    // TODO: implement paint
    final paint = Paint()..color = AppColors.pageBackground;
    canvas.drawPath(getOuterPath(rect), paint);
  }

  @override
  ShapeBorder scale(double t) {
    // If you ever want to scale your border, return a new instance:
    return PlantItemShape(usePadding: usePadding);
  }
}
