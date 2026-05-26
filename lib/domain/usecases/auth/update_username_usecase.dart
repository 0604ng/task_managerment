import '../../repositories/auth_repository.dart';

class UpdateUsernameUseCase {
  final AuthRepository repository;
  UpdateUsernameUseCase(this.repository);

  Future<void> call(String username) {
    return repository.updateUsername(username);
  }
}
