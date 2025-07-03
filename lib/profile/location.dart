import 'package:csc_picker/csc_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toastification/toastification.dart';

import '../utils/constants/colors.dart';
import '../utils/constants/icons.dart';

class LocationPicker extends StatefulWidget {
  const LocationPicker({super.key});

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  String country = '';
  String state = '';
  String city = '';

  void _updateLocation() {
    showToast(context);
  }

  void showToast(BuildContext context) {
    toastification.show(
      context: context,
      type: ToastificationType.success,
      // Change to error, warning, or info as needed
      style: ToastificationStyle.flat,
      title: const Text('Successful!'),
      description: Text('Farm location updated'),
      autoCloseDuration: const Duration(seconds: 3),
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          CSCPicker(
            selectedItemStyle: GoogleFonts.zenKakuGothicAntique(
              textStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.regularText.withValues(alpha: 0.7),
              ),
            ),
            dropdownHeadingStyle: GoogleFonts.zenKakuGothicAntique(
              textStyle: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.regularText,
              ),
            ),
            dropdownItemStyle: GoogleFonts.zenKakuGothicAntique(
              textStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.regularText.withValues(alpha: 0.9),
              ),
            ),
            layout: Layout.vertical,
            flagState: CountryFlag.ENABLE,
            onCountryChanged: (country) {},
            onStateChanged: (state) {},
            onCityChanged: (city) {},
            /* countryDropdownLabel: "*Country",
              stateDropdownLabel: "*State",
              cityDropdownLabel: "*City",*/
            //dropdownDialogRadius: 30,
            //searchBarRadius: 30,
          ),
          SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: MaterialButton(
              onPressed: _updateLocation,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 10,
                children: [
                  Text(
                    'Update location',
                    style: GoogleFonts.zenKakuGothicAntique(
                      textStyle: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.pageBackground,
                      ),
                    ),
                  ),
                  Icon(
                    AppIcons.update,
                    color: AppColors.pageBackground,
                    size: 22,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
