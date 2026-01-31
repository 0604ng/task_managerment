import '../../repositories/auth_repository.dart';

class UpdateAvatarUseCase {
  final AuthRepository repository;
  UpdateAvatarUseCase(this.repository);

  Future<void> call(String avatarUrl) {
    return repository.updateAvatar(avatarUrl);
  }
}
