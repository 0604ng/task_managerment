import '../../domain/entity/user_entity.dart';

class UserModel {
  final String id;
  final String email;
  final String username;

  UserModel({
    required this.id,
    required this.email,
    required this.username,
  });

  UserEntity toEntity() {
    return UserEntity(
      id: id,
      email: email,
      username: username,
    );
  }

  factory UserModel.fromFirebaseUser(dynamic firebaseUser) {
    return UserModel(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      username: '',
    );
  }

  factory UserModel.fromJson(String docId, Map<String, dynamic> json) {
    return UserModel(
      id: docId,
      email: json['email'] ?? '',
      username: json['username'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'username': username,
    };
  }
}
