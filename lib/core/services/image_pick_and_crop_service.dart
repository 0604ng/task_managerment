import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

class ImagePickAndCropService {
  static final ImagePicker _picker = ImagePicker();

  static Future<File?> pickAndCropAvatar(BuildContext context) async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 100,
    );

    if (picked == null) return null;

    final cropped = await ImageCropper().cropImage(
      sourcePath: picked.path,
      compressQuality: 90,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Edit avatar',
          toolbarColor: Colors.black,
          toolbarWidgetColor: Colors.white,
          lockAspectRatio: true,
          hideBottomControls: false,
          cropStyle: CropStyle.circle, // ✅ ĐÚNG CHỖ (v7)
          aspectRatioPresets: const [
            CropAspectRatioPreset.square,
          ],
        ),
        IOSUiSettings(
          title: 'Edit avatar',
          aspectRatioLockEnabled: true,
          cropStyle: CropStyle.circle, // ✅ ĐÚNG CHỖ
          aspectRatioPresets: const [
            CropAspectRatioPreset.square,
          ],
        ),
      ],
    );

    if (cropped == null) return null;

    return File(cropped.path);
  }
}
