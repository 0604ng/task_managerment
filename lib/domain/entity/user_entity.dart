import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String username;
  final String? avatarUrl;
  final bool isDarkMode;

  const UserEntity({
    required this.id,
    required this.email,
    required this.username,
    this.avatarUrl,
    this.isDarkMode = false,
  });

  UserEntity copyWith({
    String? username,
    String? avatarUrl,
    bool? isDarkMode,
  }) {
    return UserEntity(
      id: id,
      email: email,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }

  @override
  List<Object?> get props =>
      [id, email, username, avatarUrl, isDarkMode];
}
