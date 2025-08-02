// ignore_for_file: avoid_print

import 'package:farmulan/authentication/welcome_onboarding.dart';
import 'package:farmulan/utils/constants/navigation.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // --- Prevent the HighlightModeManager trying to setState on disposed widgets
  FocusManager.instance.highlightStrategy =
      FocusHighlightStrategy.alwaysTraditional;

  try {
    await Hive.initFlutter();
    var box = await Hive.openBox('farmulanDB');
  } catch (e) {
    // handle error
    print('Hive init error: $e');
  }

  try {
    await Firebase.initializeApp();

    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.playIntegrity,
      // For iOS: iosProvider: IosProvider.appAttest,
      // webProvider: ReCaptchaV3Provider('your-site-key'), // if you're using web
    );
  } catch (e) {
    print('Firebase init or App Check error: $e');
  }

  FlutterNativeSplash.remove();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return const GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        final user = snapshot.data;
        if (user == null) {
          return const WelcomePage();
        } else {
          return const MyNavBar();
        }
      },
    );
  }
}
