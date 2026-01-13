import 'package:task_manager/domain/entity/task_entity.dart';
import 'package:task_manager/domain/repositories/task_repository.dart';
import '../datasources/task_remote_data_source.dart';
import '../models/task_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDataSource remoteDataSource;

  TaskRepositoryImpl(this.remoteDataSource);

  @override
  Stream<List<TaskEntity>> getTasks(String userId) {
    return remoteDataSource.getTasks(userId).map(
          (models) => models.map((m) => m.toEntity()).toList(),
    );
  }

  @override
  Stream<List<TaskEntity>> getTasksByCategory(
      String userId,
      String categoryId,
      ) {
    return remoteDataSource
        .getTasksByCategory(userId, categoryId)
        .map(
          (models) => models.map((m) => m.toEntity()).toList(),
    );
  }

  @override
  Future<void> createTask(TaskEntity task) async {
    final model = TaskModel.fromEntity(task);
    await remoteDataSource.createTask(model);
  }

  @override
  Future<void> updateTask(TaskEntity task) async {
    final model = TaskModel.fromEntity(task);
    await remoteDataSource.updateTask(model);
  }

  @override
  Future<void> deleteTask(String taskId) async {
    await remoteDataSource.deleteTask(taskId);
  }

  @override
  Future<void> deleteTasksByCategory(String categoryId) async {
    await remoteDataSource.deleteTasksByCategory(categoryId);
  }

  @override
  Future<void> reassignTasksToAnotherCategory({
    required String oldCategoryId,
    required String newCategoryId,
  }) async {
    await remoteDataSource.reassignTasksToAnotherCategory(
      oldCategoryId,
      newCategoryId,
    );
  }
}
