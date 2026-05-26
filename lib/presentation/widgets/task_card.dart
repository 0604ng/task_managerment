import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../const/colors.dart';
import '../../../domain/entity/task_entity.dart';
import '../pages/task/edit_task_page.dart';
import '../blocs/task/task_bloc.dart';
import '../blocs/task/task_event.dart';

class TaskCard extends StatelessWidget {
  final TaskEntity task;
  const TaskCard({super.key, required this.task});

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
    final isOverdue = !task.isCompleted && task.dueDate.isBefore(DateTime.now());
    final bg = _categoryColor(task.categoryId);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
              // Left side vertical category line
              Container(
                width: 6,
                height: 96,
                color: bg.withValues(alpha: 0.8),
              ),
              const SizedBox(width: 12),

              // Custom Completion Check Circle
              GestureDetector(
                onTap: () {
                  context.read<TaskBloc>().add(
                        UpdateTaskEvent(
                          task.copyWith(isCompleted: !task.isCompleted),
                        ),
                      );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: task.isCompleted
                          ? AppColors.success
                          : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                      width: 2,
                    ),
                    color: task.isCompleted ? AppColors.success : Colors.transparent,
                  ),
                  child: task.isCompleted
                      ? const Icon(
                          Icons.check,
                          size: 16,
                          color: Colors.white,
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 12),

              // Main Details
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // Category pill tag
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: bg.withValues(alpha: 0.15),
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

                          // Time Stamp Badge
                          Row(
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                size: 14,
                                color: isOverdue ? AppColors.error : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                DateFormat('dd/MM/yyyy • HH:mm').format(task.dueDate),
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

                      // Title
                      Text(
                        task.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                          color: task.isCompleted
                              ? (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary)
                              : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      // Description
                      if (task.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          task.description,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
          ),
        ),
      ),
    );
  }
}