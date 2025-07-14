import 'package:farmulan/authentication/auth.dart';
import 'package:farmulan/authentication/welcome_onboarding.dart';
import 'package:farmulan/profile/feedback.dart';
import 'package:farmulan/profile/location.dart';
import 'package:farmulan/profile/personal_form.dart';
import 'package:farmulan/utils/constants/colors.dart';
import 'package:farmulan/utils/constants/icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileExpansionTiles extends StatefulWidget {
  const ProfileExpansionTiles({super.key});

  @override
  State<ProfileExpansionTiles> createState() => _ProfileExpansionTilesState();
}

class _ProfileExpansionTilesState extends State<ProfileExpansionTiles> {
  final User? user = Auth().currentUser;

  final List<String> profileTitles = ['Personal', 'Farm', 'Feedback', 'Logout'];
  final List<String> profileSubheadings = [
    'Update your personal details',
    'Update farm information',
    'Contact us for support',
    'Sign out of your account',
  ];
  final List<IconData> profileIcons = [
    AppIcons.personal,
    AppIcons.tractor,
    AppIcons.feedback,
    AppIcons.logout,
  ];

  final List<Widget> tileBodyList = [
    ProfileForm(),
    LocationPicker(),
    FeedbackForm(),
  ];

  Future<void> signOutAndGoHome() async {
    await Auth().signOut();
    Get.offAll(() => WelcomePage());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 8.0,
      children: List.generate(profileTitles.length, (index) {
        final isLogout = index == profileTitles.length - 1;
        return ExpansionTile(
          leading: ExpansionLeadingIcon(icon: profileIcons[index]),
          title: Text(
            profileTitles[index],
            style: GoogleFonts.zenKakuGothicAntique(
              textStyle: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.regularText.withValues(alpha: 0.8),
              ),
            ),
          ),
          subtitle: Text(
            profileSubheadings[index],
            style: GoogleFonts.zenKakuGothicAntique(
              textStyle: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.normal,
                fontStyle: FontStyle.italic,
                color: AppColors.regularText.withValues(alpha: 0.5),
              ),
            ),
          ),
          showTrailingIcon: !isLogout,
          children: isLogout ? const [] : [tileBodyList[index]],
          onExpansionChanged: (bool expanded) {
            if (isLogout && expanded) {
              signOutAndGoHome();
            }
          },
        );
      }),
    );
  }
}

class ExpansionLeadingIcon extends StatelessWidget {
  final IconData icon;
  const ExpansionLeadingIcon({super.key, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
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
            color: Color(0xff3B4056).withValues(alpha: 0.1),
            blurRadius: 10,
            offset: Offset(4, 4),
          ),
        ],
      ),
      child: Icon(
        icon,
        color: AppColors.regularText.withValues(alpha: 0.4),
        size: 16,
      ),
    );
  }
}
