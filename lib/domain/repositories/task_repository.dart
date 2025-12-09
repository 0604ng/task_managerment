import '../entity/task_entity.dart';

abstract class TaskRepository {
  Stream<List<TaskEntity>> getTasks(String userId);

  Stream<List<TaskEntity>> getTasksByCategory(
      String userId, String categoryId);

  Future<void> createTask(TaskEntity task);

  Future<void> updateTask(TaskEntity task);

  Future<void> deleteTask(String taskId);

  /// NEW — dùng cho CategoryBloc
  Future<void> reassignTasksToAnotherCategory({
    required String oldCategoryId,
    required String newCategoryId,
  });

  /// NEW — dùng cho DeleteTasksByCategoryUseCase
  Future<void> deleteTasksByCategory(String categoryId);
}
