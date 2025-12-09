// lib/presentation/pages/main/task_list_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/domain/entity/user_entity.dart';
import '../../../const/colors.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/task/task_bloc.dart';
import '../../blocs/task/task_event.dart';
import '../../blocs/task/task_state.dart';
import '../../pages/task/add_task_page.dart';
import '../../pages/task/edit_task_page.dart';
import '../../widgets/task_card.dart';
import '../../widgets/category_filter_drawer.dart';

class TaskListPage extends StatefulWidget {
  const TaskListPage({super.key, required UserEntity user});

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    // we'll dispatch load when user available below
  }

  void _loadTasksForUser(String userId) {
    if (_selectedCategoryId == null) {
      context.read<TaskBloc>().add(LoadTasks(userId));
    } else {
      context.read<TaskBloc>().add(LoadTasksByCategory(userId, _selectedCategoryId!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: navigate to Search page
            },
          ),
        ],
      ),
      drawer: CategoryFilterDrawer(
        onSelectCategory: (categoryId) {
          setState(() => _selectedCategoryId = categoryId);
          final authState = context.read<AuthBloc>().state;
          if (authState is AuthAuthenticated) _loadTasksForUser(authState.user.id);
          Navigator.of(context).pop();
        },
        onClearFilter: () {
          setState(() => _selectedCategoryId = null);
          final authState = context.read<AuthBloc>().state;
          if (authState is AuthAuthenticated) _loadTasksForUser(authState.user.id);
          Navigator.of(context).pop();
        },
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (ctx, authState) {
          if (authState is AuthAuthenticated) {
            // dispatch load
            _loadTasksForUser(authState.user.id);

            return BlocBuilder<TaskBloc, TaskState>(
              builder: (context, state) {
                if (state is TaskLoading || state is TaskInitial) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is TaskLoaded) {
                  final tasks = state.tasks;

                  if (tasks.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                              Icons.inbox,
                              size: 72,
                              color: AppColors.primary.withValues(alpha: 0.6)
                          ),
                          const SizedBox(height: 12),
                          const Text('No tasks yet', style: TextStyle(fontSize: 18)),
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddTaskPage())),
                            icon: const Icon(Icons.add),
                            label: const Text('Create your first task'),
                          ),
                        ],
                      ),
                    );
                  }

                  // sort: incomplete first
                  tasks.sort((a, b) {
                    if (a.isCompleted == b.isCompleted) return a.dueDate.compareTo(b.dueDate);
                    return a.isCompleted ? 1 : -1;
                  });

                  return RefreshIndicator(
                    onRefresh: () async {
                      _loadTasksForUser(authState.user.id);
                      // streams will refresh automatically
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        return Dismissible(
                          key: Key(task.id),
                          background: Container(
                            color: Colors.green,
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(left: 20),
                            child: const Icon(Icons.check, color: Colors.white),
                          ),
                          secondaryBackground: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Icon(Icons.delete_forever, color: Colors.white),
                          ),
                          confirmDismiss: (direction) async {
                            if (direction == DismissDirection.startToEnd) {
                              // mark complete/incomplete
                              final updated = task.copyWith(isCompleted: !task.isCompleted);
                              if (context.mounted) {
                                context.read<TaskBloc>().add(UpdateTaskEvent(updated));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(task.isCompleted ? 'Marked as Incomplete' : 'Marked as Completed')),
                                );
                              }
                              return false; // don't remove from list (stream will update)
                            } else if (direction == DismissDirection.endToStart) {
                              if (!context.mounted) return false;

                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Delete task'),
                                  content: const Text('Are you sure you want to delete this task?'),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
                                    TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                                  ],
                                ),
                              );

                              if (!context.mounted) return false;

                              if (confirmed == true) {
                                context.read<TaskBloc>().add(DeleteTaskEvent(task.id));
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Task deleted')));
                                return true;
                              }
                              return false;
                            }
                            return false;
                          },
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => EditTaskPage(task: task))),
                            child: TaskCard(task: task),
                          ),
                        );
                      },
                    ),
                  );
                } else if (state is TaskError) {
                  return Center(child: Text('Error: ${state.message}'));
                } else {
                  return const SizedBox.shrink();
                }
              },
            );
          } else if (authState is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return const Center(child: Text('Please sign in to see tasks'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddTaskPage())),
        child: const Icon(Icons.add),
      ),
    );
  }
}