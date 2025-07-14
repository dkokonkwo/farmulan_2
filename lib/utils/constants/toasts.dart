import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toastification/toastification.dart';

import 'colors.dart';

void showSuccessToast(BuildContext context, String message) {
  toastification.show(
    context: context,
    type: ToastificationType.success,
    // Change to error, warning, or info as needed
    style: ToastificationStyle.flat,
    title: const Text('Successful!'),
    description: Text(
      message,
      style: GoogleFonts.zenKakuGothicAntique(
        textStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: AppColors.contentColorGreen,
        ),
      ),
    ),
    autoCloseDuration: const Duration(seconds: 8),
    icon: const Icon(Icons.check_circle, color: Colors.white),
  );
}

void showErrorToast(BuildContext context, String message) {
  toastification.show(
    context: context,
    type: ToastificationType.error,
    // Change to error, warning, or info as needed
    style: ToastificationStyle.flat,
    title: const Text('Error!'),
    description: Text(
      message,
      style: GoogleFonts.zenKakuGothicAntique(
        textStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: AppColors.contentColorRed,
        ),
      ),
    ),
    autoCloseDuration: const Duration(seconds: 8),
    icon: const Icon(Icons.error, color: Colors.white),
  );
}

void showInfoToast(BuildContext context, String message) {
  toastification.show(
    context: context,
    type: ToastificationType.info,
    // Change to error, warning, or info as needed
    style: ToastificationStyle.flat,
    title: const Text('Info!'),
    description: Text(
      message,
      style: GoogleFonts.zenKakuGothicAntique(
        textStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: AppColors.pageBackground,
        ),
      ),
    ),
    autoCloseDuration: const Duration(seconds: 3),
    icon: const Icon(Icons.info, color: Colors.white),
  );
}
