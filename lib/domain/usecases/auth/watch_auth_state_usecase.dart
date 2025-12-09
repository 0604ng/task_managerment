// lib/domain/usecases/auth/watch_auth_state_usecase.dart
import '../../repositories/auth_repository.dart';
import '../../entity/user_entity.dart';

class WatchAuthStateUseCase {
  final AuthRepository repository;

  WatchAuthStateUseCase(this.repository);

  Stream<UserEntity?> call() {
    return repository.watchUser();
  }
}
