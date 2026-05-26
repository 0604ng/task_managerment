import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/task/task_bloc.dart';
import '../../blocs/task/task_state.dart';
import '../../widgets/task_card.dart';
import '../../../const/colors.dart';

class MissedPage extends StatelessWidget {
  const MissedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocBuilder<TaskBloc, TaskState>(
      builder: (context, state) {
        if (state is TaskInitial || state is TaskLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is TaskError) {
          return Center(
            child: Text(
              state.message,
              style: const TextStyle(color: AppColors.error),
            ),
          );
        }

        if (state is TaskLoaded) {
          final now = DateTime.now();

          // MISSED: not completed + overdue
          final missedTasks = state.tasks.where((task) {
            return !task.isCompleted && task.dueDate.isBefore(now);
          }).toList();

          if (missedTasks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.task_alt_rounded,
                    size: 72,
                    color: isDark ? AppColors.darkTextSecondary.withValues(alpha: 0.3) : AppColors.textSecondary.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No missed tasks found 🎉',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: missedTasks.length,
            itemBuilder: (context, index) {
              final task = missedTasks[index];
              return TaskCard(task: task);
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
