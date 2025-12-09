// lib/domain/usecases/auth/reset_password_usecase.dart
import '../../repositories/auth_repository.dart';

class ResetPasswordUseCase {
  final AuthRepository repository;

  ResetPasswordUseCase(this.repository);

  Future<void> call(String email) {
    return repository.sendPasswordReset(email);
  }
}
