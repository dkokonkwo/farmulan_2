import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:farmulan/utils/constants/toasts.dart';
import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../authentication/auth.dart';
import '../../farm/plant_item.dart';
import 'colors.dart';
import 'icons.dart';

class AddCropButton extends StatefulWidget {
  final VoidCallback onCropAdded;
  const AddCropButton({super.key, required this.onCropAdded});

  @override
  State<AddCropButton> createState() => _AddCropButtonState();
}

class _AddCropButtonState extends State<AddCropButton> {
  bool _pressed = false;
  final cropNameCtrl = TextEditingController();
  final plantedTimeCtrl = TextEditingController();
  String? dropdownValue;
  bool isUpdating = false;

  final List<String> isGrowingDropdown = <String>['Yes', 'No'];

  @override
  void dispose() {
    cropNameCtrl.dispose();
    plantedTimeCtrl.dispose();
    super.dispose();
  }

  Future<void> _buildStages(String farmId, String cropId) async {
    final functions = FirebaseFunctions.instance;
    try {
      final HttpsCallableResult result = await functions
          .httpsCallable('buildCropStages')
          .call(<String, dynamic>{'farmId': farmId, 'cropId': cropId});
      final stages = (result.data as Map<String, dynamic>)['stages'] as List;
      // You can now use `stages` locally if needed, or just trust that it got written server‑side.
    } on FirebaseFunctionsException catch (e) {
      if (!mounted) return;
      showErrorToast(context, 'Error building crop stages: ${e.message}');
      debugPrint('${e.message}');
    } catch (e) {
      if (!mounted) return;
      showErrorToast(context, 'Unknown error building stages: $e');
      debugPrint('Error: $e');
    }
  }

  Future<void> _addCrop() async {
    final nameText = cropNameCtrl.text.trim();
    final timeText = plantedTimeCtrl.text.trim();
    final isGrowing = dropdownValue == 'Yes';

    if (nameText.isEmpty || dropdownValue == null) {
      showErrorToast(context, 'Please fill out all fields.');
      return;
    }

    int? timeSincePlanted;
    if (isGrowing) {
      if (timeText.isEmpty) {
        showErrorToast(
          context,
          'Please tell how long you’ve planted this crop.',
        );
        return;
      }
      try {
        timeSincePlanted = int.parse(timeText);
      } catch (_) {
        showErrorToast(context, 'Time since planted must be a number.');
        return;
      }
    }

    setState(() {
      isUpdating = true;
    });

    try {
      final box = Hive.box('farmulanDB');
      final farmId = box.get('farmId') as String?;
      final user = Auth().currentUser;

      if (farmId == null || user == null) {
        showErrorToast(context, 'No farm selected or user not signed in');
        return;
      }

      // Prepare crop map
      final plantingDate = isGrowing
          ? DateTime.now().subtract(Duration(days: timeSincePlanted!))
          : null;

      final uuid = Uuid();
      final cropId = uuid.v4();

      final newCrop = {
        'cropId': cropId,
        'name': nameText,
        'isGrowing': isGrowing,
        'timePlanted': plantingDate, // Stored as DateTime in Firestore
        'growthStage': isGrowing ? 1 : 0,
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('farms')
          .doc(farmId)
          .collection('crops')
          .doc(cropId)
          .set(newCrop);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('farms')
          .doc(farmId)
          .update({'numOfCrops': FieldValue.increment(1)});

      if (isGrowing) {
        await _buildStages(farmId, cropId);
      }

      widget.onCropAdded();

      final newCropHive = {
        'cropId': cropId,
        'name': nameText,
        'isGrowing': isGrowing,
        'timePlanted': plantingDate?.millisecondsSinceEpoch,
        'growthStage': isGrowing ? 1 : 0, // initial stage is
      };

      // mirroring in Hive
      // (re‑fetch fresh data normally)
      final currentList = box.get('crops', defaultValue: []) as List;
      await box.put('crops', [...currentList, newCropHive]);
      await box.put('numOfCrops', (box.get('numOfCrops') as int? ?? 0) + 1);

      setState(() {
        isUpdating = false;
      });

      // Close the dialog
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        showSuccessToast(context, 'Crop added successfully!');
      }
    } catch (e) {
      if (!mounted) return;
      showErrorToast(context, 'Failed to add crop: $e');
      setState(() {
        isUpdating = false;
      });
    } finally {
      setState(() {
        isUpdating = false;
      });
    }
  }

  void _onTap() async {
    final width = MediaQuery.of(context).size.width;
    showDialog(
      barrierDismissible: !isUpdating,
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (dialogContext, dialogSetState) {
          return AlertDialog(
            backgroundColor: AppColors.pageBackground,
            content: Container(
              padding: EdgeInsets.all(8),
              child: Wrap(
                spacing: 10,
                runSpacing: 15,
                children: [
                  AddCropTextField(
                    label: 'Crop Name',
                    controller: cropNameCtrl,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 2.6,
                    ),
                    width: width / 1.5,
                    decoration: BoxDecoration(
                      color: Color(0xffDBE0E7),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButton<String>(
                      hint: Text(
                        'Are growing this crop?',
                        style: TextStyle(
                          fontFamily: 'Zen Kaku Gothic Antique',
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                          color: AppColors.regularText.withValues(alpha: 0.6),
                        ),
                      ),
                      style: TextStyle(
                        fontFamily: 'Zen Kaku Gothic Antique',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      isExpanded: true,
                      borderRadius: BorderRadius.circular(22),
                      icon: Icon(
                        AppIcons.downArrow,
                        color: AppColors.regularText.withValues(alpha: 0.6),
                      ),
                      iconSize: 20,
                      dropdownColor: Colors.white,
                      menuWidth: width / 1.5,
                      value: dropdownValue,
                      items: isGrowingDropdown
                          .map(
                            (s) => DropdownMenuItem(
                              value: s,
                              child: Text(
                                s,
                                style: TextStyle(
                                  fontFamily: 'Zen Kaku Gothic Antique',
                                  fontSize: 15,
                                  fontWeight: FontWeight.normal,
                                  color: AppColors.regularText.withValues(
                                    alpha: 0.6,
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (newValue) {
                        if (newValue != null) {
                          // update the dialog's local state
                          dialogSetState(() {
                            dropdownValue = newValue;
                          });
                        }
                      },
                    ),
                  ),
                  if (dropdownValue == 'Yes')
                    AddCropTextField(
                      label: 'How many days since planted?(0 for first day)',
                      controller: plantedTimeCtrl,
                      keyboardType: TextInputType.number,
                    ),
                  TextButton(
                    onPressed: isUpdating ? null : _addCrop,
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
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
                            'Add Crop',
                            style: TextStyle(
                              fontFamily: 'Zen Kaku Gothic Antique',
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: AppColors.pageBackground,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width / 2.36;
    double blur = 20.0;
    Offset distance = Offset(10, 10);
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        _onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: Container(
        width: width,
        height: width * 1.46,
        decoration: ShapeDecoration(
          shape: const PlantItemShape(usePadding: false),
          shadows: [
            BoxShadow(
              color: AppColors.white,
              blurRadius: blur,
              offset: -distance,
              inset: _pressed,
            ),
            BoxShadow(
              blurRadius: blur,
              offset: distance,
              color: AppColors.bottomShadow,
              inset: _pressed,
            ),
          ],
        ),
        child: Center(
          child: Column(
            spacing: 5,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [AppColors.primaryPurple, AppColors.primaryRed],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds),
                blendMode: BlendMode.srcIn,
                child: Icon(
                  AppIcons.plus,
                  color: AppColors.primaryPurple,
                  size: 70,
                ),
              ),
              Text(
                'Add New Crop',
                style: TextStyle(
                  fontFamily: 'Zen Kaku Gothic Antique',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryPurple.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AddCropTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool obscure;
  final TextInputType? keyboardType;
  AddCropTextField({
    super.key,
    required this.label,
    required this.controller,
    this.obscure = false,
    this.keyboardType,
  });

  final BorderRadius br = BorderRadius.circular(10);

  @override
  Widget build(BuildContext context) {
    double inputWidth = MediaQuery.of(context).size.width / 1.5;
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
        keyboardType: keyboardType,
        style: TextStyle(
          fontFamily: 'Zen Kaku Gothic Antique',
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: AppColors.primary,
        ),
        obscureText: obscure,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: label,
          labelStyle: TextStyle(
            fontFamily: 'Zen Kaku Gothic Antique',
            fontSize: 15,
            fontWeight: FontWeight.normal,
            color: AppColors.regularText.withValues(alpha: 0.8),
          ),
          hintStyle: TextStyle(
            fontFamily: 'Zen Kaku Gothic Antique',
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
