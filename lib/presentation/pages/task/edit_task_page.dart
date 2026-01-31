import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/task/task_bloc.dart';
import '../../blocs/task/task_event.dart';
import '../../../const/colors.dart';
import '../../../domain/entity/task_entity.dart';

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
  late DateTime _date;
  late TimeOfDay _time;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.task.title);
    _descCtrl = TextEditingController(text: widget.task.description);
    _date = widget.task.dueDate;
    _time = TimeOfDay.fromDateTime(widget.task.dueDate);
    _completed = widget.task.isCompleted;
  }

  Future<void> _pickDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (selected != null) setState(() => _date = selected);
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

    final dueDateTime = DateTime(
      _date.year,
      _date.month,
      _date.day,
      _time.hour,
      _time.minute,
    );

    final updated = widget.task.copyWith(
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      dueDate: dueDateTime,
      isCompleted: _completed,
    );

    context.read<TaskBloc>().add(UpdateTaskEvent(updated));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Task'),
        backgroundColor: AppColors.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(14),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  TextFormField(
                    controller: _titleCtrl,
                    decoration: const InputDecoration(labelText: 'Task name'),
                    validator: (v) =>
                    v != null && v.isNotEmpty ? null : 'Required',
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _descCtrl,
                    decoration:
                    const InputDecoration(labelText: 'Description'),
                    maxLines: 4,
                  ),
                  const SizedBox(height: 10),
                  ListTile(
                    title: const Text('Date'),
                    subtitle: Text(DateFormat.yMMMd().format(_date)),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: _pickDate,
                  ),
                  ListTile(
                    title: const Text('Time'),
                    subtitle: Text(_time.format(context)),
                    trailing: const Icon(Icons.access_time),
                    onTap: _pickTime,
                  ),
                  SwitchListTile(
                    title: const Text('Completed'),
                    value: _completed,
                    onChanged: (v) => setState(() => _completed = v),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _save,
                    child: const Text('Save'),
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
