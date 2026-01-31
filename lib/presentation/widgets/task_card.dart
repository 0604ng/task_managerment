// lib/presentation/widgets/task_card.dart
import 'package:flutter/material.dart';
import '../../../const/colors.dart';
import '../../../domain/entity/task_entity.dart';
import 'package:intl/intl.dart';

class TaskCard extends StatelessWidget {
  final TaskEntity task;
  const TaskCard({super.key, required this.task});

  Color _categoryColor(String categoryId) {
    // simple mapping — replace with Category lookup if available
    switch (categoryId) {
      case 'project':
        return AppColors.projectBg;
      case 'education':
        return AppColors.educationBg;
      case 'workout':
        return AppColors.workoutBg;
      case 'meetings':
        return AppColors.meetingsBg;
      default:
        return AppColors.surface;
    }
  }

  @override
  Widget build(BuildContext context) {
    final due = DateFormat.yMMMd().format(task.dueDate);
    final bg = _categoryColor(task.categoryId);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // checkbox
            Column(
              children: [
                Checkbox(
                  value: task.isCompleted,
                  onChanged: (_) {
                    // handled via swipe in list, but keep visual here too
                    // you can dispatch UpdateTaskEvent when tapping
                  },
                ),
              ],
            ),
            const SizedBox(width: 8),
            // content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          task.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(due, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    task.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 8),
                  // progress bar (simple visual: 0% or 100%)
                  LinearProgressIndicator(
                    value: task.isCompleted ? 1.0 : 0.0,
                    color: AppColors.primary,
                    backgroundColor: bg.withValues(alpha: 0.4),
                    minHeight: 6,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}