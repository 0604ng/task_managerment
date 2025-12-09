// lib/domain/usecases/task/delete_task_usecase.dart
import '../../repositories/task_repository.dart';

class DeleteTaskUseCase {
  final TaskRepository repository;

  DeleteTaskUseCase(this.repository);

  Future<void> call(String taskId) {
    return repository.deleteTask(taskId);
  }
}
