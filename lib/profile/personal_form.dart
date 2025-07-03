import 'package:farmulan_2/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FormField extends StatefulWidget {
  final String fieldName;
  const FormField({super.key, required this.fieldName});

  @override
  State<FormField> createState() => _FormFieldState();
}

class _FormFieldState extends State<FormField> {
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
        style: GoogleFonts.zenKakuGothicAntique(
          textStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.normal,
            color: AppColors.primary,
          ),
        ),
        obscureText: true,
        decoration: InputDecoration(
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
          labelText: widget.fieldName,
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

class FormContainer extends StatelessWidget {
  const FormContainer({super.key});

  void doSomething() {}

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          FormField(fieldName: 'First Name'),
          FormField(fieldName: 'Last Name'),
          FormField(fieldName: 'Password'),
          FormField(fieldName: 'Confirm Password'),
          TextButton(
            onPressed: doSomething,
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
