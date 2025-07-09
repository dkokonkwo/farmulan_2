import 'package:farmulan_2/farm/farm.dart';
import 'package:farmulan_2/home/home.dart';
import 'package:farmulan_2/profile/profile.dart';
import 'package:farmulan_2/utils/constants/MyAppBar.dart';
import 'package:farmulan_2/utils/constants/colors.dart';
import 'package:farmulan_2/utils/constants/custom_navbar.dart';
import 'package:flutter/material.dart';

class MyNavBar extends StatefulWidget {
  const MyNavBar({super.key});

  @override
  State<MyNavBar> createState() => _MyNavBarState();
}

class _MyNavBarState extends State<MyNavBar> {
  int _currentIndex = 0;

  late final List<Widget> _screens = [
    HomePage(navCallback: changeTab),
    const FarmPage(),
    const ProfilePage(),
  ];

  final List<bool> _appbar = [true, false, false];

  void changeTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: _appbar[_currentIndex] ? const MyAppBar() : null,
      body: _screens[_currentIndex],
      bottomNavigationBar: CustomNavBar(changeIndex: changeTab),
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
