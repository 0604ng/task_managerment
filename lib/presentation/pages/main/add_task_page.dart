// lib/presentation/pages/task/add_task_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../const/colors.dart';
import '../../../domain/entity/task_entity.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/task/task_bloc.dart';
import '../../../presentation/blocs/task/task_event.dart';


class AddTaskPage extends StatefulWidget {
  const AddTaskPage({super.key});

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  DateTime? _dueDate;
  String? _categoryId;
  String _priority = 'Medium';

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
      initialDate: now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 3650)),
    );
    if (selected != null) setState(() => _dueDate = selected);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Not authenticated')));
      return;
    }
    final userId = authState.user.id;

    final task = TaskEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // temp id - repository may override
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      isCompleted: false,
      dueDate: _dueDate ?? DateTime.now().add(const Duration(days: 1)),
      categoryId: _categoryId ?? 'default',
      userId: userId,
    );

    context.read<TaskBloc>().add(CreateTaskEvent(task));
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Task created')));
  }

  @override
  Widget build(BuildContext context) {
    final dueText = _dueDate != null ? DateFormat.yMMMd().format(_dueDate!) : 'Select due date';

    return Scaffold(
      appBar: AppBar(title: const Text('Create Task'), backgroundColor: AppColors.primary),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Form(
              key: _formKey,
              child: ListView(
                shrinkWrap: true,
                children: [
                  TextFormField(
                    controller: _titleCtrl,
                    decoration: const InputDecoration(labelText: 'Task name', hintText: 'Enter task name'),
                    validator: (v) => v != null && v.trim().isNotEmpty ? null : 'Name required',
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _descCtrl,
                    decoration: const InputDecoration(labelText: 'Description', hintText: 'Details (optional)'),
                    maxLines: 4,
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Due date'),
                    subtitle: Text(dueText),
                    trailing: IconButton(icon: const Icon(Icons.calendar_today), onPressed: _pickDate),
                    onTap: _pickDate,
                  ),
                  const SizedBox(height: 8),
                  // Category selector placeholder (you can replace with real category list)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Category'),
                    subtitle: Text(_categoryId ?? 'Default'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO: open category picker
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Category picker not implemented yet')));
                    },
                  ),
                  const SizedBox(height: 8),
                  // Priority
                  DropdownButtonFormField<String>(
                    initialValue: _priority,
                    items: const [
                      DropdownMenuItem(value: 'Low', child: Text('Low')),
                      DropdownMenuItem(value: 'Medium', child: Text('Medium')),
                      DropdownMenuItem(value: 'High', child: Text('High')),
                    ],
                    onChanged: (v) => setState(() => _priority = v ?? 'Medium'),
                    decoration: const InputDecoration(labelText: 'Priority'),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(onPressed: _save, child: const Text('Create')),
                      ),
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
