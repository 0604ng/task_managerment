import '../../domain/entity/user_entity.dart';

class UserModel {
  final String id;
  final String email;
  final String username;
  final String? avatarUrl;

  UserModel({
    required this.id,
    required this.email,
    required this.username,
    this.avatarUrl,
  });

  // 🔁 MODEL → ENTITY
  UserEntity toEntity() {
    return UserEntity(
      id: id,
      email: email,
      username: username,
      avatarUrl: avatarUrl, // 🔥 QUAN TRỌNG
    );
  }

  // 🔥 TỪ FIREBASE AUTH (chỉ auth info)
  factory UserModel.fromFirebaseUser(dynamic firebaseUser) {
    return UserModel(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      username: '',
      avatarUrl: null,
    );
  }

  // 🔥 TỪ FIRESTORE
  factory UserModel.fromJson(
      String docId, Map<String, dynamic> json) {
    return UserModel(
      id: docId,
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      avatarUrl: json['avatarUrl'], // 🔥 ADD
    );
  }

  // 🔥 LƯU FIRESTORE
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'username': username,
      'avatarUrl': avatarUrl, // 🔥 ADD
    };
  }
}
