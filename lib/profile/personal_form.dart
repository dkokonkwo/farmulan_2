import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmulan/authentication/auth.dart';
import 'package:farmulan/utils/constants/colors.dart';
import 'package:farmulan/utils/constants/toasts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: AppColors.primary,
        ),
        obscureText: obscure,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: label,
          labelStyle: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.normal,
            color: AppColors.regularText.withValues(alpha: 0.8),
          ),
          hintStyle: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.normal,
            color: AppColors.regularText.withValues(alpha: 0.8),
          ),
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
  bool isUpdating = false;

  @override
  void initState() {
    super.initState();
    final user = Auth().currentUser;
    // fetch your Firestore profile doc here, then:
    // firstNameCtrl.text = fetchedFirstName;
    // lastNameCtrl.text  = fetchedLastName;
    emailCtrl.text = user?.email ?? '';
    _loadUserProfile();
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
        firstNameCtrl.text = data['firstName'] as String? ?? '';
        lastNameCtrl.text = data['lastName'] as String? ?? '';
      }
    } catch (e) {
      if (!mounted) return;
      showErrorToast(context, 'Error loading profile: $e');
    }
  }

  Future<bool> _reauthenticate(String currentPassword) async {
    try {
      final user = Auth().currentUser;
      if (user == null || user.email == null) return false;

      // 1. Create a credential using their email + current password
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      // 2. Ask Firebase to reauthenticate
      await user.reauthenticateWithCredential(cred);
      return true;
    } on FirebaseAuthException catch (e) {
      if (!mounted) return false;
      showErrorToast(context, 'Re-authentication failed: ${e.message}');
      return false;
    }
  }

  Future<void> _updateProfile() async {
    setState(() => isUpdating = true);

    final user = Auth().currentUser;
    if (user == null) {
      showErrorToast(context, 'User not signed in');
      setState(() => isUpdating = false);
      return;
    }

    // If they entered a new password, reauthenticate then update
    if (newPassCtrl.text.isNotEmpty) {
      // First ask them for their **current** password
      final currentPassCtrl = TextEditingController();
      final confirmed = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Confirm your password'),
          content: TextField(
            controller: currentPassCtrl,
            autofocus: true,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Current password'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, currentPassCtrl.text),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      currentPassCtrl.dispose();

      if (confirmed == null || confirmed.isEmpty) {
        if (!mounted) return;
        showErrorToast(context, 'Password confirmation is required');
        setState(() => isUpdating = false);
        return;
      }

      // Re authenticate
      final ok = await _reauthenticate(confirmed);
      if (!ok) {
        setState(() => isUpdating = false);
        return;
      }

      // Now safe to update the password
      try {
        await user.updatePassword(newPassCtrl.text);
      } on FirebaseAuthException catch (e) {
        if (!mounted) return;
        showErrorToast(context, 'Password update failed: ${e.message}');
        setState(() => isUpdating = false);
        return;
      }
    }

    // merge first and last name to firestore
    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'firstName': firstNameCtrl.text.trim(),
        'lastName': lastNameCtrl.text.trim(),
      }, SetOptions(merge: true));

      await user.reload();
      if (!mounted) return;
      showSuccessToast(context, 'Profile updated');
    } catch (e) {
      if (!mounted) return;
      showErrorToast(context, 'Failed to update profile: $e');
    } finally {
      setState(() {
        isUpdating = false;
      });
    }

    setState(() {
      isUpdating = false;
    });
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
            onPressed: isUpdating ? null : _updateProfile,
            style: TextButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: isUpdating
                ? CircularProgressIndicator(
                    color: AppColors.pageBackground,
                    backgroundColor: Colors.transparent,
                  )
                : Text(
                    'Update',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.pageBackground,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
