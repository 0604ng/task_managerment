import '../../repositories/task_repository.dart';


class DeleteTasksByCategoryUseCase {
  final TaskRepository repository;

  DeleteTasksByCategoryUseCase(this.repository);

  Future<void> call(String categoryId) {
    return repository.deleteTasksByCategory(categoryId);
  }
}
