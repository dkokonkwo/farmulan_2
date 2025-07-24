import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmulan/utils/constants/bottom_sheet.dart';
import 'package:farmulan/utils/constants/toasts.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:image_picker/image_picker.dart';

import '../authentication/auth.dart';
import '../utils/constants/colors.dart';

class FarmImagePicker extends StatefulWidget {
  const FarmImagePicker({super.key});

  @override
  State<FarmImagePicker> createState() => _FarmImagePickerState();
}

class _FarmImagePickerState extends State<FarmImagePicker> {
  File? _imageFile;
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  final picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_imageFile == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      final filename = DateTime.now().millisecondsSinceEpoch.toString();
      final ref = FirebaseStorage.instance.ref('farmImages/$filename.jpg');

      final uploadTask = ref.putFile(_imageFile!);

      uploadTask.snapshotEvents.listen((event) {
        setState(() {
          _uploadProgress = event.bytesTransferred / event.totalBytes;
        });
      });

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      final myBox = Hive.box('farmulanDB');
      final farmId = myBox.get('farmId') as String? ?? '';
      final user = Auth().currentUser;

      if (farmId.isEmpty || user == null) {
        if (!mounted) return;
        showErrorToast(context, 'Please set up your farm and sign in first.');
        return;
      }

      final farmRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('farms')
          .doc(farmId);

      await farmRef.set({'farmImage': downloadUrl}, SetOptions(merge: true));

      final bytes = await _imageFile!.readAsBytes();
      await myBox.put('farmImageBytes', bytes);

      if (mounted) {
        showSuccessToast(context, 'Farm image uploaded!');
        setState(() {
          _imageFile = null;
          _uploadProgress = 0.0;
        });
      }
    } catch (e) {
      if (!mounted) return;
      showErrorToast(context, 'Failed to upload image: $e');
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          if (_imageFile != null)
            Image.file(_imageFile!, width: 200, height: 200, fit: BoxFit.cover)
          else
            const Icon(Icons.image, size: 100, color: Colors.grey),

          const SizedBox(height: 20),

          ElevatedButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.photo_library, color: AppColors.primaryRed),
            label: const Text(
              'Pick Image',
              style: TextStyle(
                fontFamily: 'Zen Kaku Gothic Antique',
                fontSize: 16,
                fontWeight: FontWeight.normal,
                color: AppColors.primaryRed,
              ),
            ),
          ),

          const SizedBox(height: 10),

          if (_imageFile != null && !_isUploading)
            ElevatedButton.icon(
              onPressed: _uploadImage,
              icon: const Icon(Icons.cloud_upload, color: AppColors.primaryRed),
              label: const Text(
                'Upload',
                style: TextStyle(
                  fontFamily: 'Zen Kaku Gothic Antique',
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  color: AppColors.primaryRed,
                ),
              ),
            ),

          if (_isUploading)
            Column(
              children: [
                const Text(
                  'Uploading...',
                  style: TextStyle(
                    fontFamily: 'Zen Kaku Gothic Antique',
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: AppColors.primaryRed,
                  ),
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: _uploadProgress,
                  color: AppColors.primaryPurple,
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class CropOptions extends StatelessWidget {
  const CropOptions({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box('farmulanDB');

    return ValueListenableBuilder(
      valueListenable: box.listenable(keys: ['crops']),
      builder: (context, Box b, _) {
        final rawDynamic = box.get('crops') as List<dynamic>? ?? [];
        final farmCrops = rawDynamic
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();

        if (farmCrops.isEmpty) {
          return Center(
            child: Text(
              'No crops added yet',
              style: TextStyle(
                fontFamily: 'Zen Kaku Gothic Antique',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.regularText,
              ),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          itemCount: farmCrops.length,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (_, i) {
            final crop = farmCrops[i];
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    crop['name'],
                    style: TextStyle(
                      fontFamily: 'Zen Kaku Gothic Antique',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryPurple,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => showEditCropSheet(context, crop),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryPurple,
                    ),
                    child: Text(
                      'Edit',
                      style: TextStyle(
                        fontFamily: 'Zen Kaku Gothic Antique',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.pageBackground,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
