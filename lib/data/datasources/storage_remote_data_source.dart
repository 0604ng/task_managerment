import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StorageRemoteDataSource {
  final FirebaseStorage storage;
  final FirebaseAuth auth;

  StorageRemoteDataSource(this.storage, this.auth);

  Future<String> uploadAvatar(File file) async {
    final uid = auth.currentUser!.uid;
    final ref = storage.ref().child('avatars/$uid.jpg');

    await ref.putFile(file);
    return await ref.getDownloadURL();
  }
}
