// lib/domain/usecases/task/create_task_usecase.dart
import '../../repositories/task_repository.dart';
import '../../entity/task_entity.dart';

class CreateTaskUseCase {
  final TaskRepository repository;

  CreateTaskUseCase(this.repository);

  Future<void> call(TaskEntity task) {
    return repository.createTask(task);
  }
}
