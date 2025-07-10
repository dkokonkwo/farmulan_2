import 'package:farmulan/authentication/auth.dart';
import 'package:farmulan/utils/constants/icons.dart';
import 'package:farmulan/utils/constants/images.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

import '../utils/constants/colors.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> _submit() async {
    try {
      await Auth().signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message ?? 'Login failed')));
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
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
            child: Column(
              children: [
                SizedBox(height: screenHeight / 20),
                Container(
                  width: screenWidth / 1.3,
                  height: screenWidth / 1.3,
                  child: Lottie.asset('assets/animations/login.json'),
                ),
                Text(
                  'Welcome back',
                  style: GoogleFonts.zenKakuGothicAntique(
                    textStyle: TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.w800,
                      color: AppColors.pageBackground,
                    ),
                  ),
                ),
                Text(
                  'Sign in to access your account',
                  style: GoogleFonts.zenKakuGothicAntique(
                    textStyle: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.normal,
                      color: AppColors.pageBackground.withValues(alpha: 0.7),
                    ),
                  ),
                ),
                SizedBox(height: 50),
                AuthFormField(
                  fieldName: 'Enter your email',
                  icon: AppIcons.sms,
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: [AutofillHints.email],
                ),
                SizedBox(height: 15),
                AuthFormField(
                  fieldName: 'Password',
                  icon: AppIcons.eye,
                  toggleIcon: AppIcons.eyeSlash,
                  controller: passwordController,
                  keyboardType: TextInputType.visiblePassword,
                  autofillHints: [AutofillHints.password],
                ),
                SizedBox(height: screenHeight / 5.5),
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    fixedSize: Size(screenWidth / 1.11, 57),
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 8,
                      children: [
                        Text(
                          'Next',
                          style: GoogleFonts.zenKakuGothicAntique(
                            textStyle: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        Icon(AppIcons.rightArrow, color: AppColors.primary),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  spacing: 5,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'New member?',
                      style: GoogleFonts.zenKakuGothicAntique(
                        textStyle: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                          color: AppColors.pageBackground.withValues(
                            alpha: 0.7,
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Get.to(SignUpPage()),
                      child: Text(
                        'Register now',
                        style: GoogleFonts.zenKakuGothicAntique(
                          textStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.contentColorRed.withValues(
                              alpha: 0.8,
                            ),
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.contentColorRed
                                .withValues(alpha: 0.8), // underline color
                            decorationThickness: 2.0, // line thickness
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool isChecked = false;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();

  Future<void> _submit() async {
    if (!isChecked) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please agree to our terms and conditions before signing up',
          ),
        ),
      );
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Password does not match')));
      return;
    }

    try {
      await Auth().createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Registration failed')),
      );
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
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
            child: Column(
              children: [
                SizedBox(height: screenHeight / 35),
                Container(
                  width: screenWidth / 1.8,
                  height: screenWidth / 1.8,
                  child: Lottie.asset('assets/animations/updatedWindmill.json'),
                ),
                Text(
                  'Getting Started',
                  style: GoogleFonts.zenKakuGothicAntique(
                    textStyle: TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.w800,
                      color: AppColors.pageBackground,
                    ),
                  ),
                ),
                Text(
                  'by creating your account',
                  style: GoogleFonts.zenKakuGothicAntique(
                    textStyle: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.normal,
                      color: AppColors.pageBackground.withValues(alpha: 0.5),
                    ),
                  ),
                ),
                SizedBox(height: 30),
                AuthFormField(
                  fieldName: 'First Name',
                  icon: AppIcons.personal,
                  controller: firstNameController,
                  keyboardType: TextInputType.text,
                ),
                SizedBox(height: 10),
                AuthFormField(
                  fieldName: 'Last Name',
                  icon: AppIcons.personal,
                  controller: lastNameController,
                  keyboardType: TextInputType.text,
                ),
                SizedBox(height: 10),
                AuthFormField(
                  fieldName: 'Valid email',
                  icon: AppIcons.sms,
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 10),
                AuthFormField(
                  fieldName: 'Password',
                  icon: AppIcons.eye,
                  toggleIcon: AppIcons.eyeSlash,
                  controller: passwordController,
                  keyboardType: TextInputType.visiblePassword,
                ),
                SizedBox(height: 10),
                AuthFormField(
                  fieldName: 'Confirm Password',
                  icon: AppIcons.eye,
                  toggleIcon: AppIcons.eyeSlash,
                  controller: confirmPasswordController,
                  keyboardType: TextInputType.visiblePassword,
                ),
                SizedBox(height: 10),
                Row(
                  spacing: 8,
                  children: [
                    Checkbox(
                      value: isChecked,
                      activeColor: AppColors.pageBackground,
                      checkColor: AppColors.primary,
                      side: BorderSide(
                        color: AppColors.pageBackground,
                        width: 2,
                      ),
                      onChanged: (newBool) {
                        setState(() {
                          isChecked = newBool!;
                        });
                      },
                    ),
                    Text(
                      'By checking the box you agree to our Terms and Conditions',
                      style: GoogleFonts.zenKakuGothicAntique(
                        textStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                          color: AppColors.pageBackground,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight / 15),
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    fixedSize: Size(screenWidth / 1.11, 57),
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 8,
                      children: [
                        Text(
                          'Next',
                          style: GoogleFonts.zenKakuGothicAntique(
                            textStyle: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        Icon(AppIcons.rightArrow, color: AppColors.primary),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  spacing: 5,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Already a member?',
                      style: GoogleFonts.zenKakuGothicAntique(
                        textStyle: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                          color: AppColors.pageBackground.withValues(
                            alpha: 0.7,
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Get.to(LoginPage()),
                      child: Text(
                        'Login',
                        style: GoogleFonts.zenKakuGothicAntique(
                          textStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.pageBackground.withValues(
                              alpha: 0.8,
                            ),
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.pageBackground
                                .withValues(alpha: 0.8), // underline color
                            decorationThickness: 2.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AuthFormField extends StatefulWidget {
  final String fieldName;
  final IconData icon;
  final IconData? toggleIcon;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final Iterable<String>? autofillHints;
  const AuthFormField({
    super.key,
    required this.fieldName,
    required this.icon,
    this.toggleIcon,
    required this.controller,
    required this.keyboardType,
    this.autofillHints,
  });

  @override
  State<AuthFormField> createState() => _AuthFormFieldState();
}

class _AuthFormFieldState extends State<AuthFormField> {
  bool obscure = true;
  final BorderRadius br = BorderRadius.circular(10);
  @override
  Widget build(BuildContext context) {
    double inputWidth = MediaQuery.of(context).size.width / 1.11;
    return Container(
      width: inputWidth,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Color(0xffC4C4C4).withValues(alpha: 0.2),
      ),
      child: TextField(
        controller: widget.controller,
        keyboardType: widget.keyboardType,
        autofillHints: widget.autofillHints,
        obscureText: widget.toggleIcon != null ? obscure : false,
        style: GoogleFonts.zenKakuGothicAntique(
          textStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.normal,
            color: AppColors.pageBackground,
          ),
        ),
        decoration: InputDecoration(
          suffixIcon: widget.toggleIcon == null
              ? Icon(
                  widget.icon,
                  color: AppColors.pageBackground.withValues(alpha: 0.6),
                )
              : IconButton(
                  icon: Icon(
                    obscure ? widget.icon : widget.toggleIcon,
                    color: AppColors.pageBackground.withValues(alpha: 0.6),
                  ),
                  onPressed: () {
                    setState(() {
                      obscure = !obscure;
                    });
                  },
                ),
          labelStyle: GoogleFonts.zenKakuGothicAntique(
            textStyle: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.normal,
              color: AppColors.pageBackground.withValues(alpha: 0.8),
            ),
          ),
          hintStyle: GoogleFonts.zenKakuGothicAntique(
            textStyle: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.normal,
              color: AppColors.pageBackground.withValues(alpha: 0.8),
            ),
          ),
          border: OutlineInputBorder(),
          labelText: widget.fieldName,
          contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
          // The default border (when not focused)
          enabledBorder: OutlineInputBorder(
            borderRadius: br, // corner radius
            borderSide: BorderSide.none,
          ),

          // The border when the field is focused
          focusedBorder: OutlineInputBorder(
            borderRadius: br,
            borderSide: BorderSide(color: AppColors.primary),
          ),

          // Optional: border when there's an error
          errorBorder: OutlineInputBorder(
            borderRadius: br,
            borderSide: BorderSide(color: Colors.red),
          ),

          // Optional: border when focused & error
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: br,
            borderSide: BorderSide(color: Colors.redAccent, width: 2),
          ),
        ),
      ),
    );
  }
}
