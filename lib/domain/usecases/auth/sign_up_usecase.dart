// lib/domain/usecases/auth/sign_up_usecase.dart
import '../../repositories/auth_repository.dart';
import '../../entity/user_entity.dart';

class SignUpUseCase {
  final AuthRepository repository;

  SignUpUseCase(this.repository);

  Future<UserEntity?> call(String email, String password, String username) {
    return repository.signUp(email, password, username);
  }
}