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
import '../../../const/colors.dart';

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

  Color _categoryColor(String categoryId) {
    switch (categoryId.toLowerCase()) {
      case 'work':
        return AppColors.learningBg; // Soft Indigo
      case 'family':
        return AppColors.familyBg;
      case 'sport':
        return AppColors.sportBg;
      case 'game':
        return AppColors.gameBg;
      case 'shopping':
        return AppColors.shoppingBg;
      case 'learning':
        return AppColors.learningBg;
      case 'hobby':
        return AppColors.hobbyBg;
      default:
        return AppColors.meetingsBg;
    }
  }

  Color _categoryTextColor(String categoryId) {
    switch (categoryId.toLowerCase()) {
      case 'work':
        return AppColors.learningText;
      case 'family':
        return AppColors.familyText;
      case 'sport':
        return AppColors.sportText;
      case 'game':
        return AppColors.gameText;
      case 'shopping':
        return AppColors.shoppingText;
      case 'learning':
        return AppColors.learningText;
      case 'hobby':
        return AppColors.hobbyText;
      default:
        return AppColors.meetingsText;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthAuthenticated) {
          return const Center(child: Text('Not logged in'));
        }

        final user = authState.user;
        final todayStr = DateFormat('EEEE, d MMMM').format(DateTime.now());

        return BlocBuilder<TaskBloc, TaskState>(
          builder: (context, taskState) {
            int total = 0;
            int completed = 0;
            int missed = 0;
            List<TaskEntity> filteredTasks = [];

            if (taskState is TaskLoaded) {
              final now = DateTime.now();
              total = taskState.tasks.length;
              completed = taskState.tasks.where((t) => t.isCompleted).length;
              missed = taskState.tasks.where((t) => !t.isCompleted && t.dueDate.isBefore(now)).length;
              filteredTasks = _filterTasks(taskState.tasks);
            }

            final todo = total - completed - missed;
            final progress = total == 0 ? 0.0 : completed / total;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// 👋 Welcome Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello, ${user.username} 👋',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            todayStr,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                        backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
                        child: user.avatarUrl == null
                            ? const Icon(Icons.person_rounded, color: AppColors.primary, size: 24)
                            : null,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  /// 📊 Progress Card (Gradient + Donut Chart)
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [const Color(0xFF1E1B4B).withValues(alpha: 0.9), const Color(0xFF0F172A).withValues(alpha: 0.95)]
                            : [AppColors.primary, AppColors.secondary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: isDark
                          ? Border.all(color: AppColors.primary.withValues(alpha: 0.25), width: 1.5)
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? Colors.black.withValues(alpha: 0.3)
                              : AppColors.primary.withValues(alpha: 0.35),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Overall Progress',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Total: $total',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          Row(
                            children: [
                              SizedBox(
                                width: 120,
                                height: 120,
                                child: PieChart(
                                  PieChartData(
                                    sectionsSpace: 4,
                                    centerSpaceRadius: 40,
                                    sections: [
                                      if (todo > 0)
                                        _pieSection(todo, isDark ? const Color(0xFF00D2FF) : Colors.white.withValues(alpha: 0.5), 16),
                                      if (completed > 0)
                                        _pieSection(completed, isDark ? const Color(0xFF00F5A0) : Colors.white, 20),
                                      if (missed > 0)
                                        _pieSection(missed, isDark ? const Color(0xFFFF5252) : Colors.black.withValues(alpha: 0.4), 16),
                                      if (total == 0)
                                        _pieSection(1, isDark ? Colors.white.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.2), 16),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _LegendItem(
                                      color: isDark ? const Color(0xFF00D2FF) : Colors.white.withValues(alpha: 0.5),
                                      label: 'To do',
                                      value: todo,
                                    ),
                                    _LegendItem(
                                      color: isDark ? const Color(0xFF00F5A0) : Colors.white,
                                      label: 'Completed',
                                      value: completed,
                                    ),
                                    _LegendItem(
                                      color: isDark ? const Color(0xFFFF5252) : Colors.black.withValues(alpha: 0.4),
                                      label: 'Missed',
                                      value: missed,
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),

                          const SizedBox(height: 20),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${(progress * 100).round()}% Completed',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 10,
                              backgroundColor: isDark
                                  ? Colors.white.withValues(alpha: 0.08)
                                  : Colors.white.withValues(alpha: 0.2),
                              color: isDark ? const Color(0xFF00F5A0) : Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  /// 📅 Sliding Pill Tab Switcher (Luxurious UI)
                  Container(
                    height: 52,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : Colors.transparent,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _TabButton(
                            title: "Today's Tasks",
                            isActive: _showToday,
                            onPressed: () => setState(() => _showToday = true),
                          ),
                        ),
                        Expanded(
                          child: _TabButton(
                            title: "Tomorrow's",
                            isActive: !_showToday,
                            onPressed: () => setState(() => _showToday = false),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// 📋 Task List (Beautified with Status and Category Pills)
                  if (filteredTasks.isEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      width: double.infinity,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.playlist_add_check_rounded,
                            size: 72,
                            color: isDark ? AppColors.darkTextSecondary.withValues(alpha: 0.3) : AppColors.textSecondary.withValues(alpha: 0.3),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No pending tasks found',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredTasks.length,
                      itemBuilder: (context, index) {
                        final task = filteredTasks[index];
                        final isOverdue = !task.isCompleted && task.dueDate.isBefore(DateTime.now());

                        return Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkSurface : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isDark ? AppColors.darkBorder : AppColors.border,
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => EditTaskPage(task: task),
                                  ),
                                );
                              },
                              child: Row(
                                children: [
                                  // Category highlight border left
                                  Container(
                                    width: 6,
                                    height: 90,
                                    color: _categoryColor(task.categoryId).withValues(alpha: 0.8),
                                  ),
                                  const SizedBox(width: 14),
                                  // Content
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              // Category Pill
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: _categoryColor(task.categoryId).withValues(alpha: 0.15),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  task.categoryId.toUpperCase(),
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w900,
                                                    color: _categoryTextColor(task.categoryId),
                                                    letterSpacing: 0.5,
                                                  ),
                                                ),
                                              ),
                                              const Spacer(),
                                              // Time Badge
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.access_time_rounded,
                                                    size: 14,
                                                    color: isOverdue ? AppColors.error : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    DateFormat('HH:mm').format(task.dueDate),
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.bold,
                                                      color: isOverdue ? AppColors.error : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            task.title,
                                            style: theme.textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 16,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          if (task.description.isNotEmpty) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              task.description,
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Status Indicator / Arrow
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Icon(
                                      isOverdue ? Icons.error_outline_rounded : Icons.pending_actions_rounded,
                                      color: isOverdue ? AppColors.error : AppColors.warning,
                                      size: 24,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  PieChartSectionData _pieSection(int value, Color color, double radius) {
    return PieChartSectionData(
      value: value.toDouble(),
      color: color,
      showTitle: false,
      radius: radius,
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
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '$value  $label',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive
              ? (isDark ? AppColors.primary : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isActive
                ? (isDark ? Colors.white : AppColors.primary)
                : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
