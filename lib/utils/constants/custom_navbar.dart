import 'package:farmulan/utils/constants/icons.dart';
import 'package:flutter/material.dart';

import 'colors.dart';

class CustomNavBar extends StatefulWidget {
  final ValueChanged<int> changeIndex;
  const CustomNavBar({super.key, required this.changeIndex});

  @override
  State<CustomNavBar> createState() => _CustomNavBarState();
}

class _CustomNavBarState extends State<CustomNavBar> {
  int selectedIndex = 0;

  final List<IconData> icons = [AppIcons.home, AppIcons.logo, AppIcons.user];

  void onNavItemTapped(int index) {
    setState(() {
      selectedIndex = index;
      widget.changeIndex(index);
      for (int i = 0; i < icons.length; i++) {
        isActiveNav[i] = i == index;
      }
    });
  }

  List<bool> isActiveNav = [true, false, false];

  int value = 0;
  bool isActive = true;

  @override
  Widget build(BuildContext context) {
    // final width = MediaQuery.of(context).size.width;
    return Container(
      color: Colors.transparent,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipPath(
            clipper: NavBarClipper(),
            child: Container(
              height: 85,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryRed.withValues(alpha: 0.8),
                    AppColors.primaryPurple.withValues(alpha: 0.9),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            left: 20,
            top: isActiveNav[0] ? -2 : 25,
            child: GestureDetector(
              onTap: () => onNavItemTapped(0),
              child: ClipPath(
                clipper: NavButtonClipper(),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(
                    vertical: 1,
                    horizontal: 1,
                  ),
                  color: isActiveNav[0]
                      ? AppColors.mainBg.withValues(alpha: 0.4)
                      : Colors.transparent,
                  child: ClipPath(
                    clipper: NavButtonClipper(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 9,
                        horizontal: 19,
                      ),
                      decoration: BoxDecoration(
                        color: isActiveNav[0] ? null : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primaryPurple,
                            AppColors.primaryRed,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Icon(
                        icons[0],
                        color: AppColors.white,
                        size: isActiveNav[0] ? 30 : 26,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            left: 0,
            right: 0,
            top: isActiveNav[1] ? -8 : 25,
            child: GestureDetector(
              onTap: () => onNavItemTapped(1),
              child: Center(
                child: ClipPath(
                  clipper: NavButtonClipper(),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(
                      vertical: 1,
                      horizontal: 1,
                    ),
                    color: isActiveNav[1]
                        ? AppColors.mainBg.withValues(alpha: 0.4)
                        : Colors.transparent,
                    child: ClipPath(
                      clipper: NavButtonClipper(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 9,
                          horizontal: 19,
                        ),
                        decoration: BoxDecoration(
                          color: isActiveNav[1] ? null : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primaryPurple,
                              AppColors.primaryRed,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Icon(
                          icons[1],
                          color: AppColors.white,
                          size: isActiveNav[1] ? 30 : 26,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            right: 20,
            top: isActiveNav[2] ? -16 : 25,
            child: GestureDetector(
              onTap: () => onNavItemTapped(2),
              child: ClipPath(
                clipper: NavButtonClipper(),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(
                    vertical: 1,
                    horizontal: 1,
                  ),
                  color: isActiveNav[2]
                      ? AppColors.mainBg.withValues(alpha: 0.4)
                      : Colors.transparent,
                  child: ClipPath(
                    clipper: NavButtonClipper(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 9,
                        horizontal: 19,
                      ),
                      decoration: BoxDecoration(
                        color: isActiveNav[2] ? null : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primaryPurple,
                            AppColors.primaryRed,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Icon(
                        icons[2],
                        color: AppColors.white,
                        size: isActiveNav[2] ? 30 : 26,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NavBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double w = size.width;
    double h = size.height;

    var path = Path();
    path.moveTo(0, h * 0.2);
    path.lineTo(0, h);
    path.lineTo(w, h);
    path.lineTo(w, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

class NavButtonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double w = size.width;
    double h = size.height;
    double borderRadius = 10.0;
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
