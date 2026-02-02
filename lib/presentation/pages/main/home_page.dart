import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/task/task_bloc.dart';
import '../../blocs/task/task_state.dart';
import '../../../domain/entity/task_entity.dart';
import '../task/edit_task_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _showToday = true;

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  List<TaskEntity> _filterTasks(List<TaskEntity> tasks) {
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));

    return tasks.where((task) {
      if (task.isCompleted) return false;

      return _showToday
          ? _isSameDay(task.dueDate, now)
          : _isSameDay(task.dueDate, tomorrow);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthAuthenticated) {
          return const Center(child: Text('Not logged in'));
        }

        final user = authState.user;

        return BlocBuilder<TaskBloc, TaskState>(
          builder: (context, taskState) {
            int total = 0;
            int completed = 0;
            int missed = 0;

            List<TaskEntity> filteredTasks = [];

            if (taskState is TaskLoaded) {
              final now = DateTime.now();

              total = taskState.tasks.length;

              completed = taskState.tasks
                  .where((t) => t.isCompleted)
                  .length;

              missed = taskState.tasks
                  .where((t) =>
              !t.isCompleted && t.dueDate.isBefore(now))
                  .length;

              filteredTasks = _filterTasks(taskState.tasks);
            }

            final todo = total - completed - missed;
            final progress = total == 0 ? 0.0 : completed / total;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// 👋 Welcome
                  Text(
                    'Welcome, ${user.username} 👋',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 20),

                  /// 📊 Progress Card
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Task Progress',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          Row(
                            children: [
                              SizedBox(
                                width: 140,
                                height: 140,
                                child: PieChart(
                                  PieChartData(
                                    sectionsSpace: 2,
                                    centerSpaceRadius: 40,
                                    sections: [
                                      if (todo > 0)
                                        _pieSection(todo, Colors.orange),
                                      if (completed > 0)
                                        _pieSection(
                                            completed, Colors.green),
                                      if (missed > 0)
                                        _pieSection(missed, Colors.black),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    _LegendItem(
                                      color: Colors.orange,
                                      label: 'To do',
                                      value: todo,
                                    ),
                                    _LegendItem(
                                      color: Colors.green,
                                      label: 'Completed',
                                      value: completed,
                                    ),
                                    _LegendItem(
                                      color: Colors.black,
                                      label: 'Missed',
                                      value: missed,
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),

                          const SizedBox(height: 16),

                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${(progress * 100).round()}%',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Total: $total',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 12,
                              backgroundColor: Colors.grey.shade300,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  /// 📅 Tabs
                  Row(
                    children: [
                      Expanded(
                        child: _TabButton(
                          title: "Today's tasks",
                          isActive: _showToday,
                          onPressed: () =>
                              setState(() => _showToday = true),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _TabButton(
                          title: "Tomorrow's tasks",
                          isActive: !_showToday,
                          onPressed: () =>
                              setState(() => _showToday = false),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// 📋 Task List
                  if (filteredTasks.isEmpty)
                    const Center(child: Text('No tasks'))
                  else
                    Column(
                      children: filteredTasks.map((task) {
                        final isOverdue = !task.isCompleted &&
                            task.dueDate
                                .isBefore(DateTime.now());

                        return InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    EditTaskPage(task: task),
                              ),
                            );
                          },
                          child: Card(
                            margin:
                            const EdgeInsets.only(bottom: 12),
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor: isOverdue
                                        ? Colors.red
                                        .withValues(alpha: 0.15)
                                        : Colors.orange
                                        .withValues(alpha: 0.15),
                                    child: Icon(
                                      isOverdue
                                          ? Icons
                                          .warning_amber_rounded
                                          : Icons.pending_actions,
                                      color: isOverdue
                                          ? Colors.red
                                          : Colors.orange,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          task.title,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight:
                                            FontWeight.w600,
                                          ),
                                        ),
                                        if (task
                                            .description.isNotEmpty) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            task.description,
                                            style: TextStyle(
                                              color:
                                              Colors.grey[700],
                                            ),
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
                                              DateFormat(
                                                  'dd/MM/yyyy • HH:mm')
                                                  .format(
                                                  task.dueDate),
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
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  PieChartSectionData _pieSection(int value, Color color) {
    return PieChartSectionData(
      value: value.toDouble(),
      color: color,
      showTitle: false,
      radius: 30,
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final int value;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          CircleAvatar(radius: 6, backgroundColor: color),
          const SizedBox(width: 8),
          Text('$value  $label'),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String title;
  final bool isActive;
  final VoidCallback onPressed;

  const _TabButton({
    required this.title,
    required this.isActive,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor:
        isActive ? Colors.blue : Colors.grey.shade300,
        foregroundColor:
        isActive ? Colors.white : Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      onPressed: onPressed,
      child: Text(title),
    );
  }
}
