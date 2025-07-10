import 'package:farmulan/utils/constants/icons.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toastification/toastification.dart';

import '../utils/constants/colors.dart';

class FeedbackForm extends StatefulWidget {
  const FeedbackForm({super.key});

  @override
  State<FeedbackForm> createState() => _FeedbackFormState();
}

class _FeedbackFormState extends State<FeedbackForm> {
  final _controller = TextEditingController();
  final _borderRadius = BorderRadius.circular(10);

  void _sendMessage() {
    final message = _controller.text.trim();
    if (message.isEmpty) return;
    print('Sending message: $message');
    showToast(context);
  }

  void showToast(BuildContext context) {
    toastification.show(
      context: context,
      type: ToastificationType.success,
      // Change to error, warning, or info as needed
      style: ToastificationStyle.flat,
      title: const Text('Successful!'),
      description: Text('Feedback sent!'),
      autoCloseDuration: const Duration(seconds: 3),
      icon: const Icon(Icons.check_circle, color: AppColors.pageBackground),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        spacing: 10,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          TextField(
            controller: _controller,
            minLines: 3,
            maxLines: 6,
            style: GoogleFonts.zenKakuGothicAntique(
              textStyle: TextStyle(fontSize: 16, color: AppColors.primary),
            ),
            decoration: InputDecoration(
              hintText: 'Type your feedback…',
              hintStyle: GoogleFonts.zenKakuGothicAntique(
                textStyle: TextStyle(
                  fontSize: 15,
                  color: AppColors.regularText.withValues(alpha: 0.8),
                ),
              ),
              filled: true,
              fillColor: Color(0xffF4F7FB),
              contentPadding: EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: _borderRadius,
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: _borderRadius,
                borderSide: BorderSide(color: AppColors.primary),
              ),
            ),
          ),
          SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: Icon(AppIcons.send, color: AppColors.pageBackground),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}
