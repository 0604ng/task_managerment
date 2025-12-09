// lib/presentation/screen/task_list_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../presentation/blocs/task/task_bloc.dart';
import '../presentation/blocs/task/task_event.dart';
import '../presentation/blocs/task/task_state.dart';
import '../presentation/widgets/task_card.dart';
import '../presentation/widgets/category_filter_drawer.dart';
import '../../../domain/entity/user_entity.dart';
import 'add_task_page.dart';

class TaskListPage extends StatefulWidget {
  final UserEntity user;

  const TaskListPage({super.key, required this.user});

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  @override
  void initState() {
    super.initState();
    context.read<TaskBloc>().add(LoadTasks(widget.user.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Hello, ${widget.user.username}")),
      drawer: CategoryFilterDrawer(onSelectCategory: (String categoryId) {  }, onClearFilter: () {  },),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddTaskPage()),
        ),
      ),
      body: BlocBuilder<TaskBloc, TaskState>(
        builder: (ctx, state) {
          if (state is TaskLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TaskLoaded) {
            if (state.tasks.isEmpty) {
              return const Center(child: Text("No tasks yet"));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: state.tasks.length,
              itemBuilder: (_, i) => TaskCard(task: state.tasks[i]),
            );
          }

          return const Center(child: Text("Something went wrong"));
        },
      ),
    );
  }
}
