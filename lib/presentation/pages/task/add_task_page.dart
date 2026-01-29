import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../const/colors.dart';
import '../../../domain/entity/task_entity.dart';

import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';

import '../../blocs/task/task_bloc.dart';
import '../../blocs/task/task_event.dart';

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({super.key});

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  DateTime _dueDate = DateTime.now();
  TimeOfDay _time = const TimeOfDay(hour: 9, minute: 0);
  String _category = 'Work';

  final List<String> _categories = const [
    'Work',
    'Family',
    'Sport',
    'Game',
    'Shopping',
    'Learning',
    'Hobby',
  ];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (selected != null) setState(() => _dueDate = selected);
  }

  Future<void> _pickTime() async {
    final selected = await showTimePicker(
      context: context,
      initialTime: _time,
    );
    if (selected != null) setState(() => _time = selected);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    final dueDateTime = DateTime(
      _dueDate.year,
      _dueDate.month,
      _dueDate.day,
      _time.hour,
      _time.minute,
    );

    final task = TaskEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      isCompleted: false,
      dueDate: dueDateTime,
      categoryId: _category.toLowerCase(), // work, family, ...
      userId: authState.user.id,
    );

    context.read<TaskBloc>().add(CreateTaskEvent(task));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final dateText = DateFormat.yMMMd().format(_dueDate);
    final timeText = _time.format(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Task'),
        backgroundColor: AppColors.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  /// TITLE
                  TextFormField(
                    controller: _titleCtrl,
                    decoration:
                    const InputDecoration(labelText: 'Task name'),
                    validator: (v) =>
                    v != null && v.isNotEmpty ? null : 'Required',
                  ),

                  const SizedBox(height: 12),

                  /// DESCRIPTION
                  TextFormField(
                    controller: _descCtrl,
                    decoration:
                    const InputDecoration(labelText: 'Description'),
                    maxLines: 3,
                  ),

                  const SizedBox(height: 12),

                  /// DATE
                  ListTile(
                    title: const Text('Date'),
                    subtitle: Text(dateText),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: _pickDate,
                  ),

                  /// TIME
                  ListTile(
                    title: const Text('Time'),
                    subtitle: Text(timeText),
                    trailing: const Icon(Icons.access_time),
                    onTap: _pickTime,
                  ),

                  const SizedBox(height: 12),

                  /// CATEGORY DROPDOWN
                  DropdownButtonFormField<String>(
                    initialValue: _category,
                    decoration:
                    const InputDecoration(labelText: 'Category'),
                    items: _categories
                        .map(
                          (c) => DropdownMenuItem(
                        value: c,
                        child: Text(c),
                      ),
                    )
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _category = v);
                    },
                  ),

                  const SizedBox(height: 20),

                  /// CREATE
                  ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Create'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
