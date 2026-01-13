import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class UserFirestoreDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  UserFirestoreDataSource(this._firestore, this._auth);

  Future<void> createUser(UserModel user) async {
    await _firestore
        .collection('users')
        .doc(user.id)
        .set(user.toJson());
  }

  Future<UserModel?> getCurrentUser() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;

    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;

    return UserModel.fromJson(doc.id, doc.data()!);

  }
}
