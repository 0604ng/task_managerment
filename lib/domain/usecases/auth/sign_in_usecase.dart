// lib/domain/usecases/auth/sign_in_usecase.dart
import '../../repositories/auth_repository.dart';
import '../../entity/user_entity.dart';

class SignInUseCase {
  final AuthRepository repository;

  SignInUseCase(this.repository);

  Future<UserEntity?> call(String email, String password) {
    return repository.signIn(email, password);
  }
}