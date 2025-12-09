// lib/presentation/widgets/category_filter_drawer.dart
import 'package:flutter/material.dart';

class CategoryFilterDrawer extends StatelessWidget {
  final void Function(String categoryId) onSelectCategory;
  final VoidCallback onClearFilter;

  const CategoryFilterDrawer({
    super.key,
    required this.onSelectCategory,
    required this.onClearFilter,
  });

  @override
  Widget build(BuildContext context) {
    // placeholder list — replace with real category stream later
    final categories = [
      {'id': 'project', 'name': 'Project'},
      {'id': 'education', 'name': 'Education'},
      {'id': 'workout', 'name': 'Workout'},
      {'id': 'meetings', 'name': 'Meetings'},
    ];

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            ListTile(
              title: const Text('Filter by category', style: TextStyle(fontWeight: FontWeight.bold)),
              trailing: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.clear),
              title: const Text('All categories'),
              onTap: onClearFilter,
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final c = categories[index];
                  return ListTile(
                    leading: CircleAvatar(backgroundColor: Colors.grey.shade200, child: Text(c['name']![0])),
                    title: Text(c['name']!),
                    onTap: () => onSelectCategory(c['id']!),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
