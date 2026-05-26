import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel?> signIn(String email, String password);
  Future<UserModel?> signUp(String email, String password, String username);
  Future<void> signOut();
  Future<void> sendPasswordReset(String email);
  Stream<UserModel?> watchUser();

  // 🔥 ADD
  Future<void> updateAvatar(String avatarUrl);
  Future<void> updateUsername(String username);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  AuthRemoteDataSourceImpl(this.auth);

  Future<UserModel?> _mapFirebaseUser(User? user) async {
    if (user == null) return null;

    final doc =
    await firestore.collection("users").doc(user.uid).get();
    final data = doc.data() ?? {};

    return UserModel(
      id: user.uid,
      email: user.email ?? "",
      username: data["username"] ?? "",
      avatarUrl: data["avatarUrl"],
    );
  }

  @override
  Future<UserModel?> signIn(String email, String password) async {
    final credentials = await auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return _mapFirebaseUser(credentials.user);
  }

  @override
  Future<UserModel?> signUp(
      String email, String password, String username) async {
    final credentials =
    await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credentials.user;
    if (user == null) return null;

    await firestore.collection("users").doc(user.uid).set({
      "id": user.uid,
      "email": email,
      "username": username,
      "avatarUrl": null,
    });

    return _mapFirebaseUser(user);
  }

  @override
  Future<void> signOut() async => auth.signOut();

  @override
  Future<void> sendPasswordReset(String email) =>
      auth.sendPasswordResetEmail(email: email);

  @override
  Stream<UserModel?> watchUser() {
    return auth.authStateChanges().asyncMap(_mapFirebaseUser);
  }

  // 🔥 NEW
  @override
  Future<void> updateAvatar(String avatarUrl) async {
    final uid = auth.currentUser!.uid;
    await firestore.collection("users").doc(uid).set({
      "avatarUrl": avatarUrl,
    }, SetOptions(merge: true));
  }

  @override
  Future<void> updateUsername(String username) async {
    final uid = auth.currentUser!.uid;
    await firestore.collection("users").doc(uid).set({
      "username": username,
    }, SetOptions(merge: true));
  }
}
