import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/services/notification_service.dart';
import '../../../domain/usecases/task/get_tasks_usecase.dart';
import '../../../domain/usecases/task/get_tasks_by_category_usecase.dart';
import '../../../domain/usecases/task/create_task_usecase.dart';
import '../../../domain/usecases/task/update_task_usecase.dart';
import '../../../domain/usecases/task/delete_task_usecase.dart';

import 'task_event.dart';
import 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final GetTasksUseCase getTasksUseCase;
  final GetTasksByCategoryUseCase getTasksByCategoryUseCase;
  final CreateTaskUseCase createTaskUseCase;
  final UpdateTaskUseCase updateTaskUseCase;
  final DeleteTaskUseCase deleteTaskUseCase;

  TaskBloc({
    required this.getTasksUseCase,
    required this.getTasksByCategoryUseCase,
    required this.createTaskUseCase,
    required this.updateTaskUseCase,
    required this.deleteTaskUseCase,
  }) : super(TaskInitial()) {
    on<LoadTasks>((event, emit) async {
      await emit.forEach(
        getTasksUseCase(event.userId),
        onData: (tasks) => TaskLoaded(tasks),
        onError: (e, _) => TaskError(e.toString()),
      );
    });

    on<LoadTasksByCategory>((event, emit) async {
      await emit.forEach(
        getTasksByCategoryUseCase(event.userId, event.categoryId),
        onData: (tasks) => TaskLoaded(tasks),
        onError: (e, _) => TaskError(e.toString()),
      );
    });

    /// CREATE
    on<CreateTaskEvent>((event, emit) async {
      await createTaskUseCase(event.task);

      await NotificationService.scheduleTaskNotification(
        taskId: event.task.id,
        title: '⏰ Task reminder',
        body: event.task.title,
        dateTime: event.task.dueDate,
      );
    });

    /// UPDATE
    on<UpdateTaskEvent>((event, emit) async {
      await updateTaskUseCase(event.task);

      await NotificationService.cancel(event.task.id);

      if (!event.task.isCompleted) {
        await NotificationService.scheduleTaskNotification(
          taskId: event.task.id,
          title: '⏰ Task reminder',
          body: event.task.title,
          dateTime: event.task.dueDate,
        );
      }
    });

    /// DELETE
    on<DeleteTaskEvent>((event, emit) async {
      await deleteTaskUseCase(event.taskId);
      await NotificationService.cancel(event.taskId);
    });
  }
}
