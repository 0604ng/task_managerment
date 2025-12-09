// lib/presentation/screen/edit_task_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entity/task_entity.dart';
import '../presentation/blocs/task/task_bloc.dart';
import '../presentation/blocs/task/task_event.dart';

class EditTaskPage extends StatefulWidget {
  final TaskEntity task;

  const EditTaskPage({super.key, required this.task});

  @override
  State<EditTaskPage> createState() => _EditTaskPageState();
}

class _EditTaskPageState extends State<EditTaskPage> {
  late TextEditingController _titleCtrl;
  late TextEditingController _descCtrl;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.task.title);
    _descCtrl = TextEditingController(text: widget.task.description);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Task")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _titleCtrl, decoration: const InputDecoration(labelText: "Title")),
            const SizedBox(height: 12),
            TextField(controller: _descCtrl, decoration: const InputDecoration(labelText: "Description")),
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text("Save"),
              onPressed: () {
                final updated = widget.task.copyWith(
                  title: _titleCtrl.text.trim(),
                  description: _descCtrl.text.trim(),
                );

                context.read<TaskBloc>().add(UpdateTaskEvent(updated));

                Navigator.pop(context);
              },
            )
          ],
        ),
      ),
    );
  }
}
