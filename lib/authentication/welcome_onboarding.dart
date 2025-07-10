import 'package:farmulan/authentication/login_register.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

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
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                Row(children: [Text('Logo')]),
                SizedBox(height: screenHeight / 3),
                Text(
                  'Welcome to FarMulan app',
                  style: GoogleFonts.zenKakuGothicAntique(
                    textStyle: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.pageBackground,
                    ),
                  ),
                ),
                Text(
                  'Grow your crops efficiently and monitor your farm from any in the world',
                  style: GoogleFonts.zenKakuGothicAntique(
                    textStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                      color: AppColors.pageBackground.withValues(alpha: 0.8),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Get.to(SignUpPage()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.pageBackground,
                    minimumSize: Size(screenWidth / 1.11, 50),
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Register',
                      style: GoogleFonts.zenKakuGothicAntique(
                        textStyle: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Get.to(LoginPage()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    minimumSize: Size(screenWidth / 1.11, 50),
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
                      style: GoogleFonts.zenKakuGothicAntique(
                        textStyle: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.pageBackground,
                        ),
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
    );
  }
}
