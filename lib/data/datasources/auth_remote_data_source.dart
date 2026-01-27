import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel?> signIn(String email, String password);
  Future<UserModel?> signUp(String email, String password, String username);
  Future<void> signOut();
  Future<void> sendPasswordReset(String email);
  Stream<UserModel?> watchUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  AuthRemoteDataSourceImpl(this.auth);

  // ⭐ HÀM HELPER ĐỂ MAP FIREBASE USER SANG USER MODEL
  Future<UserModel?> _mapFirebaseUser(User? user) async {
    if (user == null) return null;

    final doc = await firestore.collection("users").doc(user.uid).get();

    return UserModel(
      id: user.uid,
      email: user.email ?? "",
      username: doc.data()?["username"] ?? "",
    );
  }

  @override
  Future<UserModel?> signIn(String email, String password) async {
    final credentials = await auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    // ⭐ SỬ DỤNG HÀM HELPER
    return _mapFirebaseUser(credentials.user);
  }

  @override
  Future<UserModel?> signUp(String email, String password, String username) async {
    final credentials = await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credentials.user;

    if (user == null) return null;

    // ⭐ LƯU USERNAME VÀO FIRESTORE
    await firestore.collection("users").doc(user.uid).set({
      "id": user.uid,
      "email": email,
      "username": username,
    });

    // ⭐ SỬ DỤNG HÀM HELPER THAY VÌ TẠO UserModel TRỰC TIẾP
    return _mapFirebaseUser(user);
  }

  @override
  Future<void> signOut() async => auth.signOut();

  @override
  Future<void> sendPasswordReset(String email) =>
      auth.sendPasswordResetEmail(email: email);

  @override
  Stream<UserModel?> watchUser() {
    // ⭐ SỬ DỤNG HÀM HELPER
    return auth.authStateChanges().asyncMap((firebaseUser) async {
      return _mapFirebaseUser(firebaseUser);
    });
  }
}