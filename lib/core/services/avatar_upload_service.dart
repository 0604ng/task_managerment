import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AvatarUploadService {
  static Future<String> upload(File file) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw 'User not authenticated';

      // ✅ QUAN TRỌNG: Dùng instance MẶC ĐỊNH, không chỉ định bucket
      final ref = FirebaseStorage.instance
          .ref()
          .child('avatars/$uid.jpg');

      debugPrint('🔍 Uploading to: ${ref.bucket}');
      debugPrint('🔍 Path: ${ref.fullPath}');

      await ref.putFile(
        file,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final url = await ref.getDownloadURL();
      debugPrint('✅ Upload success: $url');

      return url;

    } catch (e) {
      debugPrint('❌ Upload error: $e');
      rethrow;
    }
  }
}
