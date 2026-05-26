import 'package:task_manager/domain/entity/user_entity.dart';
import 'package:task_manager/domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remote;

  AuthRepositoryImpl(this.remote);

  @override
  Future<UserEntity?> signIn(String email, String password) async {
    final model = await remote.signIn(email, password);
    return model?.toEntity();
  }

  @override
  Future<UserEntity?> signUp(
      String email, String password, String username) async {
    final model = await remote.signUp(email, password, username);
    return model?.toEntity();
  }

  @override
  Future<void> signOut() async {
    await remote.signOut();
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    await remote.sendPasswordReset(email);
  }

  @override
  Stream<UserEntity?> watchUser() {
    return remote.watchUser().map((model) => model?.toEntity());
  }

  @override
  Future<void> updateAvatar(String avatarUrl) async {
    await remote.updateAvatar(avatarUrl);
  }

  @override
  Future<void> updateUsername(String username) async {
    await remote.updateUsername(username);
  }
}
