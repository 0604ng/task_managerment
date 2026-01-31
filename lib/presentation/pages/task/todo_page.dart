// lib/presentation/pages/task/todo_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/task/task_bloc.dart';
import '../../blocs/task/task_event.dart';
import '../../blocs/task/task_state.dart';
import 'edit_task_page.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  @override
  void initState() {
    super.initState();

    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<TaskBloc>().add(
        LoadTasks(authState.user.id),
      );
    }
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'work':
        return Icons.work;
      case 'family':
        return Icons.family_restroom;
      case 'sport':
        return Icons.sports_soccer;
      case 'game':
        return Icons.videogame_asset;
      case 'shopping':
        return Icons.shopping_cart;
      case 'learning':
        return Icons.school;
      case 'hobby':
        return Icons.palette;
      default:
        return Icons.label;
    }
  }

  Color _categoryColor(String category) {
    switch (category) {
      case 'work':
        return Colors.blue;
      case 'family':
        return Colors.pink;
      case 'sport':
        return Colors.green;
      case 'game':
        return Colors.purple;
      case 'shopping':
        return Colors.orange;
      case 'learning':
        return Colors.indigo;
      case 'hobby':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy • HH:mm').format(dateTime);
  }

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

          /// ✅ CHỈ TODO: chưa complete + CHƯA quá hạn
          final todos = state.tasks.where((task) {
            return !task.isCompleted && task.dueDate.isAfter(now);
          }).toList();

          if (todos.isEmpty) {
            return const Center(child: Text('No to-do tasks'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: todos.length,
            itemBuilder: (context, index) {
              final task = todos[index];

              return InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => EditTaskPage(task: task),
                    ),
                  );
                },
                child: Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          backgroundColor: _categoryColor(task.categoryId)
                              .withValues(alpha: 0.15),
                          child: Icon(
                            _categoryIcon(task.categoryId),
                            color: _categoryColor(task.categoryId),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                task.title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (task.description.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  task.description,
                                  style:
                                  TextStyle(color: Colors.grey[700]),
                                ),
                              ],
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.access_time,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _formatDateTime(task.dueDate),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.pending_actions,
                          color: Colors.orange,
                        ),
                      ],
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
