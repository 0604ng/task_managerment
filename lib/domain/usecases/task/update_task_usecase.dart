// lib/domain/usecases/task/update_task_usecase.dart
import '../../repositories/task_repository.dart';
import '../../entity/task_entity.dart';

class UpdateTaskUseCase {
  final TaskRepository repository;

  UpdateTaskUseCase(this.repository);

  Future<void> call(TaskEntity task) {
    return repository.updateTask(task);
  }
}
