import 'package:farmulan/farm/farm.dart';
import 'package:farmulan/profile/profile.dart';
import 'package:farmulan/utils/constants/colors.dart';
import 'package:farmulan/utils/constants/icons.dart';
import 'package:farmulan/utils/constants/navigation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class GNavBar extends StatefulWidget {
  const GNavBar({super.key});

  @override
  State<GNavBar> createState() => _GNavBarState();
}

class _GNavBarState extends State<GNavBar> {
  int _currentIndex = 0;

  late final List<Widget> _screens = [
    // const HomePage(),
    const FarmPage(),
    const ProfilePage(),
  ];

  final List<bool> _appbar = [true, false, false];

  void _changeTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: NavBarClipper(),
      child: Container(
        height: 85,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 2,
          ),
          gradient: LinearGradient(
            colors: [
              AppColors.secondary.withValues(alpha: 0.8),
              AppColors.primary.withValues(alpha: 0.9),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: GNav(
            backgroundColor: Colors.transparent,
            color: AppColors.subheadingText,
            activeColor: AppColors.primary,
            tabBackgroundColor: AppColors.navBg,
            tabBorderRadius: 20.0,
            tabMargin: const EdgeInsets.all(5),
            iconSize: 30,
            textStyle: GoogleFonts.zenKakuGothicAntique(
              textStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            gap: 15,
            padding: const EdgeInsets.all(8),
            tabs: [
              GButton(
                icon: AppIcons.home,
                text: 'Home',
                borderRadius: BorderRadius.circular(12),
              ),
              GButton(
                icon: AppIcons.logo,
                text: 'Farm',
                borderRadius: BorderRadius.circular(12),
              ),
              GButton(
                icon: AppIcons.user,
                text: 'Profile',
                borderRadius: BorderRadius.circular(12),
              ),
            ],
            onTabChange: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            selectedIndex: _currentIndex,
          ),
        ),
      ),
    );
  }
}
