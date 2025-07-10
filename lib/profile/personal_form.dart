import 'package:farmulan/authentication/auth.dart';
import 'package:farmulan/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool obscure;
  CustomTextField({
    super.key,
    required this.label,
    required this.controller,
    this.obscure = false,
  });

  final BorderRadius br = BorderRadius.circular(10);

  @override
  Widget build(BuildContext context) {
    double inputWidth = MediaQuery.of(context).size.width / 2.3;
    return Container(
      width: inputWidth,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Color(0xffF4F7FB),
        boxShadow: [
          BoxShadow(
            color: Color(0xff3B4056).withValues(alpha: 0.15),
            offset: Offset(0, 8),
            blurRadius: 20,
            spreadRadius: 0,
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        style: GoogleFonts.zenKakuGothicAntique(
          textStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.normal,
            color: AppColors.primary,
          ),
        ),
        obscureText: obscure,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.zenKakuGothicAntique(
            textStyle: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.normal,
              color: AppColors.regularText.withValues(alpha: 0.8),
            ),
          ),
          hintStyle: GoogleFonts.zenKakuGothicAntique(
            textStyle: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.normal,
              color: AppColors.regularText.withValues(alpha: 0.8),
            ),
          ),
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
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

class ProfileForm extends StatefulWidget {
  const ProfileForm({super.key});

  @override
  State<ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  final firstNameCtrl = TextEditingController();
  final lastNameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final newPassCtrl = TextEditingController();
  final confirmPassCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final user = Auth().currentUser;
    // fetch your Firestore profile doc here, then:
    // firstNameCtrl.text = fetchedFirstName;
    // lastNameCtrl.text  = fetchedLastName;
    emailCtrl.text = user?.email ?? '';
  }

  @override
  void dispose() {
    firstNameCtrl.dispose();
    lastNameCtrl.dispose();
    emailCtrl.dispose();
    newPassCtrl.dispose();
    confirmPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    //   validate controller ans update details
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          CustomTextField(label: 'First Name', controller: firstNameCtrl),
          CustomTextField(label: 'Last Name', controller: lastNameCtrl),
          CustomTextField(
            label: 'email',
            controller: emailCtrl,
            obscure: false,
          ),
          CustomTextField(
            label: 'New Password',
            controller: newPassCtrl,
            obscure: true,
          ),
          CustomTextField(
            label: 'Confirm New Password',
            controller: confirmPassCtrl,
            obscure: true,
          ),
          TextButton(
            onPressed: _updateProfile,
            style: TextButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Update',
              style: GoogleFonts.zenKakuGothicAntique(
                textStyle: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.pageBackground,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
