import '../../repositories/task_repository.dart';

class ReassignTasksUseCase {
  final TaskRepository repository;

  ReassignTasksUseCase(this.repository);

  Future<void> call({
    required String oldCategoryId,
    required String newCategoryId,
  }) {
    return repository.reassignTasksToAnotherCategory(
      oldCategoryId: oldCategoryId,
      newCategoryId: newCategoryId,
    );
  }
}
