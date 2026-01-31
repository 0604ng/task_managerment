import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../const/colors.dart';
import '../../blocs/task/task_bloc.dart';
import '../../blocs/task/task_state.dart';
import '../../widgets/task_card.dart';
import '../../../domain/entity/task_entity.dart';

class TaskHistoryPage extends StatelessWidget {
  const TaskHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task history'),
        backgroundColor: AppColors.primary,
      ),
      body: BlocBuilder<TaskBloc, TaskState>(
        builder: (context, state) {
          if (state is TaskInitial || state is TaskLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TaskError) {
            return Center(child: Text(state.message));
          }

          if (state is TaskLoaded) {
            final tasks = state.tasks;
            final now = DateTime.now();

            final todo = tasks.where((t) =>
            !t.isCompleted && t.dueDate.isAfter(now)
            ).toList();

            final completed = tasks.where((t) =>
            t.isCompleted
            ).toList();

            final missed = tasks.where((t) =>
            !t.isCompleted && t.dueDate.isBefore(now)
            ).toList();

            if (tasks.isEmpty) {
              return const Center(
                child: Text('No task history'),
              );
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _Section(
                  title: '📝 Todo',
                  tasks: todo,
                ),
                _Section(
                  title: '✅ Completed',
                  tasks: completed,
                ),
                _Section(
                  title: '⏰ Missed',
                  tasks: missed,
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<TaskEntity> tasks;

  const _Section({
    required this.title,
    required this.tasks,
  });

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...tasks.map(
              (task) => TaskCard(task: task),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
