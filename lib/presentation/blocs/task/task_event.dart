import '../../../domain/entity/task_entity.dart';

abstract class TaskEvent {}

class LoadTasks extends TaskEvent {
  final String userId;
  LoadTasks(this.userId);
}

class LoadTasksByCategory extends TaskEvent {
  final String userId;
  final String categoryId;

  LoadTasksByCategory(this.userId, this.categoryId);
}

class CreateTaskEvent extends TaskEvent {
  final TaskEntity task;
  CreateTaskEvent(this.task);
}

class UpdateTaskEvent extends TaskEvent {
  final TaskEntity task;
  UpdateTaskEvent(this.task);
}

class DeleteTaskEvent extends TaskEvent {
  final String taskId;
  DeleteTaskEvent(this.taskId);
}
