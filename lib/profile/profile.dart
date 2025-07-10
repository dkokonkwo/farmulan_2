import 'package:farmulan/profile/expansion_tiles.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

import '../utils/constants/colors.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    double imageSize = MediaQuery.of(context).size.width / 1.8;
    double blur = 30.0;
    Offset distance = Offset(20, 20);
    return SingleChildScrollView(
      child: Center(
        child: Column(
          children: [
            SizedBox(height: 60),
            Container(
              width: imageSize,
              height: imageSize,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xffDBE0E7), Color(0xffF8FBFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomCenter,
                ),
                boxShadow: [
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
              child: Lottie.asset('assets/animations/IoTfarm.json'),
            ),
            SizedBox(height: 20),
            Text(
              'Update Your Profile',
              style: GoogleFonts.zenKakuGothicAntique(
                textStyle: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
            SizedBox(height: 20),
            ProfileExpansionTiles(),
          ],
        ),
      ),
    );
  }
}

class RotatingGradientCircle extends StatefulWidget {
  final double size;
  const RotatingGradientCircle({super.key, required this.size});

  @override
  State<RotatingGradientCircle> createState() => _RotatingGradientCircleState();
}

class _RotatingGradientCircleState extends State<RotatingGradientCircle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(); // loops forever
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gradient = LinearGradient(
      colors: [
        AppColors.primaryPurple,
        AppColors.primaryRed,
        AppColors.primaryPurple,
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Center(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.rotate(
            angle: _controller.value * 2 * 3.1416, // full rotation
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: gradient,
              ),
            ),
          );
        },
      ),
    );
  }
}
