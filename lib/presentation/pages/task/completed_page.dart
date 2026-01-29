// lib/presentation/pages/task/completed_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../blocs/task/task_bloc.dart';
import '../../blocs/task/task_state.dart';
import '../../blocs/task/task_event.dart';
import 'edit_task_page.dart';

class CompletedPage extends StatelessWidget {
  const CompletedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TaskBloc, TaskState>(
      builder: (context, state) {
        // ⏳ LOADING
        if (state is TaskInitial || state is TaskLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // ❌ ERROR
        if (state is TaskError) {
          return Center(
            child: Text(
              state.message,
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        // ✅ DATA
        if (state is TaskLoaded) {
          final completedTasks =
          state.tasks.where((t) => t.isCompleted).toList();

          if (completedTasks.isEmpty) {
            return const Center(
              child: Text('No completed tasks yet'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: completedTasks.length,
            itemBuilder: (context, index) {
              final task = completedTasks[index];

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
                      Icons.check_circle,
                      color: Colors.green,
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
                          'Done on ${DateFormat.yMMMd().format(task.dueDate)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),

                    /// 🔄 UNDO BUTTON
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.undo,
                        color: Colors.orange,
                      ),
                      onPressed: () {
                        context.read<TaskBloc>().add(
                          UpdateTaskEvent(
                            task.copyWith(isCompleted: false),
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
