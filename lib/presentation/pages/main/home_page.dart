import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/task/task_bloc.dart';
import '../../blocs/task/task_state.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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

            if (taskState is TaskLoaded) {
              total = taskState.tasks.length;
              completed =
                  taskState.tasks.where((t) => t.isCompleted).length;
              missed = 0; // tạm thời
            }

            final todo = total - completed - missed;
            final progress = total == 0 ? 0.0 : completed / total;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 👋 Welcome
                  Text(
                    'Welcome, ${user.username} 👋',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 20),

                  // 📊 Progress Card
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

                          // PIE + STATS
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
                                      _pieSection(
                                          todo, Colors.orange),
                                      _pieSection(
                                          completed, Colors.green),
                                      _pieSection(
                                          missed, Colors.black),
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

                          // % + Total
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

                  // 📅 Tabs
                  Row(
                    children: const [
                      Expanded(
                        child: _TabButton(
                          title: "Today's tasks",
                          isActive: true,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _TabButton(
                          title: "Tomorrow's tasks",
                          isActive: false,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  if (taskState is TaskLoaded &&
                      taskState.tasks.isEmpty)
                    const Center(child: Text('No tasks')),
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

  const _TabButton({
    required this.title,
    required this.isActive,
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
      onPressed: () {},
      child: Text(title),
    );
  }
}
