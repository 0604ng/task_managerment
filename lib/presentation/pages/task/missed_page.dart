// lib/presentation/pages/task/missed_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../blocs/task/task_bloc.dart';
import '../../blocs/task/task_state.dart';
import '../../blocs/task/task_event.dart';
import 'edit_task_page.dart';

class MissedPage extends StatelessWidget {
  const MissedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TaskBloc, TaskState>(
      builder: (context, state) {
        if (state is TaskInitial || state is TaskLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is TaskError) {
          return Center(
            child: Text(
              state.message,
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        if (state is TaskLoaded) {
          final now = DateTime.now();

          /// ✅ MISSED: chưa complete + đã quá hạn
          final missedTasks = state.tasks.where((task) {
            return !task.isCompleted && task.dueDate.isBefore(now);
          }).toList();

          if (missedTasks.isEmpty) {
            return const Center(
              child: Text('No missed tasks 🎉'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: missedTasks.length,
            itemBuilder: (context, index) {
              final task = missedTasks[index];

              return InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => EditTaskPage(task: task),
                    ),
                  );
                },
                child: Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.red,
                    ),
                    title: Text(
                      task.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (task.description.isNotEmpty)
                          Text(task.description),
                        const SizedBox(height: 4),
                        Text(
                          'Due: ${DateFormat('dd/MM/yyyy • HH:mm').format(task.dueDate)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.redAccent,
                          ),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                      ),
                      tooltip: 'Mark as completed',
                      onPressed: () {
                        context.read<TaskBloc>().add(
                          UpdateTaskEvent(
                            task.copyWith(isCompleted: true),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
