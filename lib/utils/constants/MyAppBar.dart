import 'package:farmulan/utils/constants/colors.dart';
import 'package:farmulan/utils/constants/icons.dart';
import 'package:farmulan/utils/constants/plant_details_appbar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyAppBar extends StatefulWidget implements PreferredSizeWidget {
  const MyAppBar({super.key});

  @override
  State<MyAppBar> createState() => _MyAppBarState();

  @override
  // TODO: implement preferredSize
  Size get preferredSize => const Size.fromHeight(80);
}

class _MyAppBarState extends State<MyAppBar> {
  void doSomething() {}
  Offset distance = Offset(2, 2);
  double blur = 5;
  @override
  Widget build(BuildContext context) {
    return AppBar(
      surfaceTintColor: AppColors.pageBackground,
      backgroundColor: AppColors.pageBackground,
      toolbarHeight: 80,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Good Morning!',
            style: GoogleFonts.zenKakuGothicAntique(
              textStyle: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          Text(
            'Charlie Chaplin',
            style: GoogleFonts.zenKakuGothicAntique(
              textStyle: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
                color: AppColors.regularText.withValues(alpha: 0.5),
              ),
            ),
          ),
        ],
      ),
      actions: [
        NeumorphicButton(icon: AppIcons.bell, onTap: () => doSomething()),
        const SizedBox(width: 20),
        NeumorphicButton(icon: AppIcons.settings, onTap: () => doSomething()),
        const SizedBox(width: 20),
      ],
    );
  }
}
