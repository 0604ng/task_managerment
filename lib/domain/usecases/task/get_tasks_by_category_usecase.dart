// lib/domain/usecases/task/get_tasks_by_category_usecase.dart
import '../../repositories/task_repository.dart';
import '../../entity/task_entity.dart';

class GetTasksByCategoryUseCase {
  final TaskRepository repository;

  GetTasksByCategoryUseCase(this.repository);

  Stream<List<TaskEntity>> call(String userId, String categoryId) {
    return repository.getTasksByCategory(userId, categoryId);
  }
}
