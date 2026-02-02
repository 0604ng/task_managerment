import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ImagePickService {
  static final ImagePicker _picker = ImagePicker();

  static Future<File?> pickAvatar() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
      maxWidth: 1024,
      maxHeight: 1024,
    );

    if (picked == null) return null;
    return File(picked.path);
  }
}
