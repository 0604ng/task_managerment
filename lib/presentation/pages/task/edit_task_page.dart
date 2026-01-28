// lib/presentation/pages/task/edit_task_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../blocs/task/task_bloc.dart';
import '../../blocs/task/task_event.dart';
import '../../../const/colors.dart';
import '../../../domain/entity/task_entity.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditTaskPage extends StatefulWidget {
  final TaskEntity task;
  const EditTaskPage({super.key, required this.task});

  @override
  State<EditTaskPage> createState() => _EditTaskPageState();
}

class _EditTaskPageState extends State<EditTaskPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleCtrl;
  late TextEditingController _descCtrl;
  DateTime? _dueDate;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.task.title);
    _descCtrl = TextEditingController(text: widget.task.description);
    _dueDate = widget.task.dueDate;
    _completed = widget.task.isCompleted;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 3650)),
    );
    if (selected != null) setState(() => _dueDate = selected);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final updated = widget.task.copyWith(
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      dueDate: _dueDate,
      isCompleted: _completed,
    );

    context.read<TaskBloc>().add(UpdateTaskEvent(updated));
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Task updated')));
  }

  @override
  Widget build(BuildContext context) {
    final dueText = _dueDate != null ? DateFormat.yMMMd().format(_dueDate!) : 'Select due date';

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Task'), backgroundColor: AppColors.primary),
      body: Padding(
        padding: const EdgeInsets.all(14),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Form(
              key: _formKey,
              child: ListView(
                shrinkWrap: true,
                children: [
                  TextFormField(
                    controller: _titleCtrl,
                    decoration: const InputDecoration(labelText: 'Task name'),
                    validator: (v) => v != null && v.trim().isNotEmpty ? null : 'Name required',
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _descCtrl,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 4,
                  ),
                  const SizedBox(height: 10),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Due date'),
                    subtitle: Text(dueText),
                    trailing: IconButton(icon: const Icon(Icons.calendar_today), onPressed: _pickDate),
                    onTap: _pickDate,
                  ),
                  SwitchListTile(
                    title: const Text('Completed'),
                    value: _completed,
                    onChanged: (v) => setState(() => _completed = v),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: OutlinedButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel'))),
                      const SizedBox(width: 8),
                      Expanded(child: ElevatedButton(onPressed: _save, child: const Text('Save'))),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
