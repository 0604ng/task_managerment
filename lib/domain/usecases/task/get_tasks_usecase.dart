// lib/domain/usecases/task/get_tasks_usecase.dart
import '../../repositories/task_repository.dart';
import '../../entity/task_entity.dart';

class GetTasksUseCase {
  final TaskRepository repository;

  GetTasksUseCase(this.repository);

  Stream<List<TaskEntity>> call(String userId) {
    return repository.getTasks(userId);
  }
}
