import 'package:farmulan/farm/settings_tiles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../authentication/auth.dart';
import '../profile/expansion_tiles.dart';
import '../utils/constants/colors.dart';
import '../utils/constants/icons.dart';

class SettingsTab extends StatefulWidget {
  const SettingsTab({super.key});

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  final User? user = Auth().currentUser;

  final List<String> titles = ['Edit Farm Image', 'Your Crops'];
  final List<String> subheadings = [
    'Add or update your farm image',
    'Edit your crop details',
  ];
  final List<IconData> profileIcons = [AppIcons.editImg, AppIcons.tractor];

  final List<Widget> tiles = [FarmImagePicker(), CropOptions()];

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 8.0,
      children: List.generate(titles.length, (index) {
        return ExpansionTile(
          leading: ExpansionLeadingIcon(icon: profileIcons[index]),
          title: Text(
            titles[index],
            style: TextStyle(
              fontFamily: 'Zen Kaku Gothic Antique',
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.regularText.withValues(alpha: 0.8),
            ),
          ),
          subtitle: Text(
            subheadings[index],
            style: TextStyle(
              fontFamily: 'Zen Kaku Gothic Antique',
              fontSize: 15,
              fontWeight: FontWeight.normal,
              fontStyle: FontStyle.italic,
              color: AppColors.regularText.withValues(alpha: 0.5),
            ),
          ),
          showTrailingIcon: true,
          children: [tiles[index]],
        );
      }),
    );
  }
}
