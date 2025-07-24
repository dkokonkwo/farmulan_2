import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmulan/utils/constants/colors.dart';
import 'package:farmulan/utils/constants/toasts.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../../authentication/auth.dart';
import 'add_buttons.dart';

void showEditCropSheet(BuildContext context, Map<String, dynamic> plantInfo) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => CropBottomSheet(plantInfo: plantInfo),
  );
}

class CropBottomSheet extends StatefulWidget {
  final Map<String, dynamic> plantInfo;
  const CropBottomSheet({super.key, required this.plantInfo});

  @override
  State<CropBottomSheet> createState() => _CropBottomSheetState();
}

class _CropBottomSheetState extends State<CropBottomSheet> {
  late TextEditingController cropNameCtrl;
  late TextEditingController plantedTimeCtrl;
  String? dropdownValue;
  bool isUpdating = false;

  final List<String> isGrowingDropdown = <String>['Yes', 'No'];

  Timestamp? _originalTimePlanted;

  @override
  void initState() {
    super.initState();
    cropNameCtrl = TextEditingController(
      text: widget.plantInfo['name'] as String?,
    );
    final bool? isGrowing = widget.plantInfo['isGrowing'] as bool?;
    dropdownValue = (isGrowing == true) ? 'Yes' : 'No';
    // _originalTimePlanted = widget.plantInfo['timePlanted'] as Timestamp?;
    if (isGrowing!) {
      final raw = widget.plantInfo['timePlanted'];
      DateTime plantedDate;
      if (raw is DateTime) {
        plantedDate = raw;
      } else if (raw is Timestamp) {
        // in case some entries are still Timestamps
        plantedDate = raw.toDate();
      } else {
        // no date stored → treat as 0 days
        plantedDate = DateTime.now();
      }

      final daysSince = DateTime.now().difference(plantedDate).inDays;
      plantedTimeCtrl = TextEditingController(text: daysSince.toString());
    } else {
      plantedTimeCtrl = TextEditingController(text: '');
    }

    // final days = _originalTimePlanted == null
    //     ? ''
    //     : DateTime.now()
    //           .difference(_originalTimePlanted!.toDate())
    //           .inDays
    //           .toString();
    // plantedTimeCtrl = TextEditingController(text: days);
  }

  @override
  void dispose() {
    cropNameCtrl.dispose();
    plantedTimeCtrl.dispose();
    super.dispose();
  }

  Future<void> _editCrop() async {
    final nameText = cropNameCtrl.text.trim();
    final isGrowing = dropdownValue == 'Yes';

    if (nameText.isEmpty || dropdownValue == null) {
      showErrorToast(context, 'Please fill out all fields.');
      return;
    }

    int? daysSince;
    if (isGrowing) {
      if (plantedTimeCtrl.text.trim().isEmpty) {
        showErrorToast(context, 'Please tell how many days since planted.');
        return;
      }
      daysSince = int.tryParse(plantedTimeCtrl.text.trim());
      if (daysSince == null) {
        showErrorToast(context, 'Time since planted must be a number.');
        return;
      }
    }

    setState(() => isUpdating = true);
    try {
      final box = Hive.box('farmulanDB');
      final farmId = box.get('farmId') as String?;
      final user = Auth().currentUser;
      if (farmId == null || user == null) {
        showErrorToast(context, 'Farm ID or User missing');
        return;
      }

      final farmDoc = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('farms')
          .doc(farmId);

      // Construct old & new crop maps
      // final oldCrop = {
      //   'name': widget.plantInfo['name'],
      //   'isGrowing': widget.plantInfo['isGrowing'],
      //   // reconstruct a Timestamp for comparison
      //   'timePlanted': Timestamp.fromDate(
      //     DateTime.now().subtract(
      //       Duration(days: widget.plantInfo['timePlanted']),
      //     ),
      //   ),
      //   'growthStage': widget.plantInfo['growthStage'],
      // };

      final Map<String, dynamic> oldCrop = {
        'name': widget.plantInfo['name'],
        'isGrowing': widget.plantInfo['isGrowing'],
        'timePlanted':
            _originalTimePlanted, // Use the stored original Timestamp
        'growthStage': widget.plantInfo['growthStage'],
      };

      // final newCrop = {
      //   'name': nameText,
      //   'isGrowing': isGrowing,
      //   'timePlanted': isGrowing
      //       ? Timestamp.fromDate(
      //           DateTime.now().subtract(Duration(days: daysSince!)),
      //         )
      //       : null,
      //   'growthStage': isGrowing ? 1 : 0,
      // };
      final Map<String, dynamic> newCrop = {
        'name': nameText,
        'isGrowing': isGrowing,
        'timePlanted': isGrowing
            ? Timestamp.fromDate(
                DateTime.now().subtract(Duration(days: daysSince!)),
              )
            : null, // If not growing, timePlanted is null
        'growthStage': isGrowing ? 1 : 0,
      };

      // Firestore: remove old, add new
      await farmDoc.update({
        'crops': FieldValue.arrayRemove([oldCrop]),
      });
      await farmDoc.update({
        'crops': FieldValue.arrayUnion([newCrop]),
      });

      // Hive mirror
      final rawList = box.get('crops') as List<dynamic>? ?? [];
      final current = rawList
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      // remove by matching name + planted-date
      final timestamp = newCrop['timePlanted'] as Timestamp?;
      final hiveCrop = {
        'name': newCrop['name'],
        'isGrowing': newCrop['isGrowing'],
        'timePlanted': timestamp?.toDate(), // <-- DateTime instead of Timestamp
        'growthStage': newCrop['growthStage'],
      };

      current.removeWhere((m) {
        if (m['name'] != oldCrop['name']) return false;
        final dynamic mRaw = m['timePlanted'];
        final dynamic oRaw = oldCrop['timePlanted'];
        if (mRaw == null && oRaw == null) {
          return true;
        }
        if (mRaw is Timestamp && oRaw is Timestamp) {
          return mRaw.toDate().isAtSameMomentAs(oRaw.toDate());
        }
        return false;
      });
      current.add(hiveCrop);
      await box.put('crops', current);

      if (!mounted) return;
      Navigator.of(context).pop();
      showSuccessToast(context, 'Crop updated!');
    } catch (e) {
      print('Error editing crop: $e');
      showErrorToast(context, 'Failed to update crop: $e');
    } finally {
      if (mounted) setState(() => isUpdating = false);
    }
  }

  Future<void> _deleteCrop() async {
    setState(() => isUpdating = true);
    try {
      final box = Hive.box('farmulanDB');
      final farmId = box.get('farmId') as String?;
      final user = Auth().currentUser;
      if (farmId == null || user == null) {
        showErrorToast(context, 'Farm ID or User missing');
        return;
      }

      final farmDoc = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('farms')
          .doc(farmId);

      // Build old crop map as above
      final oldCrop = {
        'name': widget.plantInfo['name'],
        'isGrowing': widget.plantInfo['isGrowing'],
        'timePlanted': Timestamp.fromDate(
          DateTime.now().subtract(
            Duration(days: widget.plantInfo['timePlanted']),
          ),
        ),
        'growthStage': widget.plantInfo['growthStage'],
      };
      // final Map<String, dynamic> oldCrop = {
      //   'name': widget.plantInfo['name'],
      //   'isGrowing': widget.plantInfo['isGrowing'],
      //   'timePlanted': _originalTimePlanted,
      //   'growthStage': widget.plantInfo['growthStage'],
      // };

      // Firestore: remove it & decrement
      await farmDoc.update({
        'crops': FieldValue.arrayRemove([oldCrop]),
        'numOfCrops': FieldValue.increment(-1),
      });

      // Hive mirror
      final current = (box.get('crops') as List<dynamic>)
          .cast<Map<String, dynamic>>();
      current.removeWhere(
        (m) =>
            m['name'] == oldCrop['name'] &&
            (m['timePlanted'] as Timestamp).toDate() ==
                (oldCrop['timePlanted'] as Timestamp).toDate(),
      );
      await box.put('crops', current);
      await box.put('numOfCrops', (box.get('numOfCrops') as int) - 1);

      if (!mounted) return;
      Navigator.of(context).pop();
      showSuccessToast(context, 'Crop deleted.');
    } catch (e) {
      showErrorToast(context, 'Failed to delete crop: $e');
    } finally {
      if (mounted) setState(() => isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 16,
        left: 16,
        right: 16,
      ),
      child: Container(
        width: width,
        height: height / 2,
        padding: EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: AppColors.pageBackground,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            spacing: 15,
            children: [
              // Crop name
              AddCropTextField(label: 'Crop Name', controller: cropNameCtrl),

              // Is Growing?
              Text(
                'Are you growing this crop?',
                style: TextStyle(
                  fontFamily: 'Zen Kaku Gothic Antique',
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.pageHeadingText,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2.6),
                width: width / 1.5,
                decoration: BoxDecoration(
                  color: Color(0xffDBE0E7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButton<String>(
                  hint: const Text('Are you growing this crop?'),
                  value: dropdownValue,
                  isExpanded: true,
                  items: isGrowingDropdown
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (v) => setState(() => dropdownValue = v),
                ),
              ),

              // Days since planted (if applicable)
              if (dropdownValue == 'Yes')
                AddCropTextField(
                  label: 'Days since planted',
                  controller: plantedTimeCtrl,
                  keyboardType: TextInputType.number,
                ),

              const SizedBox(height: 10),

              // Edit button
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.primaryPurple,
                  fixedSize: Size(width / 2.5, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: isUpdating ? null : _editCrop,
                child: isUpdating
                    ? const CircularProgressIndicator(
                        color: AppColors.pageBackground,
                      )
                    : const Text(
                        'Save Changes',
                        style: TextStyle(
                          fontFamily: 'Zen Kaku Gothic Antique',
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColors.pageBackground,
                        ),
                      ),
              ),

              // Delete button
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.contentColorRed,
                  fixedSize: Size(width / 2.5, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: isUpdating ? null : _deleteCrop,
                child: const Text(
                  'Delete Crop',
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
      ),
    );
  }
}
