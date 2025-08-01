import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmulan/utils/constants/colors.dart';
import 'package:farmulan/utils/constants/icons.dart';
import 'package:farmulan/utils/constants/plant_details_appbar.dart';
import 'package:farmulan/utils/constants/toasts.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../../authentication/auth.dart';

class MyAppBar extends StatefulWidget implements PreferredSizeWidget {
  const MyAppBar({super.key});

  @override
  State<MyAppBar> createState() => _MyAppBarState();

  @override
  // TODO: implement preferredSize
  Size get preferredSize => const Size.fromHeight(80);
}

class _MyAppBarState extends State<MyAppBar> {
  String firstName = '';
  String lastName = '';

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final user = Auth().currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          firstName = data['firstName'] as String? ?? '';
          lastName = data['lastName'] as String? ?? '';
        });
        final box = Hive.box('farmulanDB');
        await box.put('firstName', firstName);
        await box.put('lastName', lastName);
        await box.put('testFunction', 'hope this works');
      }
    } catch (e) {
      if (!mounted) return;
      showErrorToast(context, 'Error loading profile: $e');
    }
  }

  String getGreeting() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      return 'Good Morning!';
    } else if (hour >= 12 && hour < 17) {
      return 'Good Afternoon!';
    } else if (hour >= 17 && hour < 21) {
      return 'Good Evening!';
    } else {
      return 'Good Night!';
    }
  }

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
            getGreeting(),
            style: TextStyle(
              fontFamily: 'Zen Kaku Gothic Antique',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          Text(
            '$firstName $lastName',
            style: TextStyle(
              fontFamily: 'Zen Kaku Gothic Antique',
              fontSize: 15,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
              color: AppColors.regularText.withValues(alpha: 0.5),
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
