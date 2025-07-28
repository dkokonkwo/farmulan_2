import 'package:farmulan/authentication/login_register.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../utils/constants/colors.dart';
import '../utils/constants/images.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(AppImages.background),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                children: [
                  SizedBox(height: screenHeight / 10),
                  Row(
                    children: [
                      Image.asset(
                        'assets/splash_screen/welcome_logo.png',
                        width: screenWidth / 8,
                      ),
                      Image.asset(
                        'assets/splash_screen/welcome_branding.png',
                        width: screenWidth / 1.7,
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight / 3),
                  Text(
                    'Welcome to FarMulan app',
                    style: TextStyle(
                      fontFamily: 'Zen Kaku Gothic Antique',
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.pageBackground,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Grow your crops efficiently and monitor your farm from any in the world',
                    style: TextStyle(
                      fontFamily: 'Zen Kaku Gothic Antique',
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                      color: AppColors.pageBackground.withValues(alpha: 0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 50),
                  ElevatedButton(
                    onPressed: () => Get.to(SignUpPage()),
                    style: ElevatedButton.styleFrom(
                      elevation: 0.0,
                      shadowColor: Colors.transparent,
                      backgroundColor: AppColors.pageBackground,
                      fixedSize: Size(screenWidth / 1.11, 57),
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Register',
                        style: TextStyle(
                          fontFamily: 'Zen Kaku Gothic Antique',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Get.to(LoginPage()),
                    style: ElevatedButton.styleFrom(
                      elevation: 0.0,
                      shadowColor: Colors.transparent,
                      backgroundColor: Colors.transparent,
                      fixedSize: Size(screenWidth / 1.11, 57),
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: AppColors.pageBackground,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Login',
                        style: TextStyle(
                          fontFamily: 'Zen Kaku Gothic Antique',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.pageBackground,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
