// ignore_for_file: avoid_print

import 'package:farmulan_2/utils/constants/navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  try {
    await Hive.initFlutter();
    var box = await Hive.openBox('farmulanDB');
  } catch (e) {
    // handle error
    print('Hive init error: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  @override
  void initState() {
    super.initState();
    initialization();
  }

  void initialization() async {
    print('pausing...replaced with authentication with firebase');
    await Future.delayed(const Duration(seconds: 1));
    print('unpausing');
    FlutterNativeSplash.remove();
  }

  @override
  Widget build(BuildContext context) {
    return const GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyNavBar(),
    );
  }
}
