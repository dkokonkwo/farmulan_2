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
    _loadCrop();
  }

  @override
  void dispose() {
    cropNameCtrl.dispose();
    plantedTimeCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadCrop() async {
    final user = Auth().currentUser;
    final farmId = Hive.box('farmulanDB').get('farmId') as String?;
    final cropId = widget.plantInfo['cropId'] as String?;

    if (farmId == null || user == null) {
      showErrorToast(context, 'Farm ID or User missing');
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('farms')
          .doc(farmId)
          .collection('crops')
          .doc(cropId)
          .get();

      if (!doc.exists) return;

      final data = doc.data()!;
      final name = data['name'] as String? ?? '';
      final isGrowing = data['isGrowing'] as bool? ?? false;
      final ts = data['timePlanted'] as Timestamp?;

      // compute days since planted if applicable
      final daysText = isGrowing && ts != null
          ? DateTime.now().difference(ts.toDate()).inDays.toString()
          : '';

      if (mounted) {
        setState(() {
          cropNameCtrl.text = name;
          dropdownValue = isGrowing ? 'Yes' : 'No';
          plantedTimeCtrl.text = daysText;
        });
      }
    } catch (e) {
      if (mounted) showErrorToast(context, 'Failed to load crop: $e');
    }
  }

  Future<void> _editCrop() async {
    final nameText = cropNameCtrl.text.trim();
    final isGrowing = dropdownValue == 'Yes';
    final cropId = widget.plantInfo['cropId'] as String?;

    if (nameText.isEmpty || dropdownValue == null || cropId == null) {
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

    if (mounted) setState(() => isUpdating = true);
    try {
      final box = Hive.box('farmulanDB');
      final farmId = box.get('farmId') as String?;
      final user = Auth().currentUser;
      if (farmId == null || user == null) {
        showErrorToast(context, 'Farm ID or User missing');
        return;
      }

      final plantingDate = isGrowing
          ? DateTime.now().subtract(Duration(days: daysSince!))
          : null; // If not growing, timePlanted is null

      final Map<String, dynamic> newCrop = {
        'cropId': cropId,
        'name': nameText,
        'isGrowing': isGrowing,
        'timePlanted': plantingDate,
        'growthStage': isGrowing ? 1 : 0,
      };

      // Update Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('farms')
          .doc(farmId)
          .collection('crops')
          .doc(cropId)
          .update(newCrop);

      // Updating Hive (Hive mirror)
      final Map<String, dynamic> newCropHive = {
        'cropId': cropId,
        'name': nameText,
        'isGrowing': isGrowing,
        'timePlanted': plantingDate,
        'growthStage': isGrowing ? 1 : 0,
      };

      final rawList = box.get('crops') as List<dynamic>? ?? [];
      final updatedList = rawList
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();

      // remove by matching cropId
      updatedList.removeWhere((m) => m['cropId'] == cropId);
      updatedList.add(newCropHive);

      await box.put('crops', updatedList);

      if (mounted) {
        Navigator.of(context).pop();
        showSuccessToast(context, 'Crop updated!');
      }
    } catch (e) {
      debugPrint('Error editing crop: $e');
      if (mounted) showErrorToast(context, 'Failed to update crop: $e');
    } finally {
      if (mounted) setState(() => isUpdating = false);
    }
  }

  Future<void> _deleteCrop() async {
    if (mounted) setState(() => isUpdating = true);
    try {
      final box = Hive.box('farmulanDB');
      final farmId = box.get('farmId') as String?;
      final user = Auth().currentUser;
      final cropId = widget.plantInfo['cropId'] as String?;

      if (farmId == null || user == null || cropId == null) {
        showErrorToast(context, 'Missing farm or crop ID');
        return;
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('farms')
          .doc(farmId)
          .collection('crops')
          .doc(cropId)
          .delete();

      final current = (box.get('crops') as List<dynamic>)
          .cast<Map<String, dynamic>>();
      current.removeWhere((m) => m['cropId'] == cropId);
      await box.put('crops', current);

      await box.put('numOfCrops', (box.get('numOfCrops') as int? ?? 1) - 1);

      if (mounted) {
        Navigator.of(context).pop();
        showSuccessToast(context, 'Crop deleted.');
      }
    } catch (e) {
      if (!mounted) return;
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
