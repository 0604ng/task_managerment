import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../pages/main/home_page.dart';
import '../pages/task/todo_page.dart';
import '../pages/task/completed_page.dart';
import '../pages/task/missed_page.dart';
import '../pages/main/profile_page.dart';
import '../pages/task/add_task_page.dart';

import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';
import '../blocs/auth/auth_state.dart';

import '../blocs/category/category_bloc.dart';
import '../blocs/category/category_event.dart';

import '../blocs/task/task_bloc.dart';
import '../blocs/task/task_event.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  bool _categoryLoaded = false;
  bool _taskLoaded = false; // 🔥 QUAN TRỌNG

  final List<Widget> _pages = const [
    HomePage(),
    TodoPage(),
    CompletedPage(),
    MissedPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, authState) {
        if (authState is AuthAuthenticated) {
          final userId = authState.user.id;

          // 🔥 LOAD CATEGORY (1 LẦN)
          if (!_categoryLoaded) {
            context.read<CategoryBloc>().add(
              LoadCategories(userId),
            );
            _categoryLoaded = true;
          }

          // 🔥 LOAD TASKS (CỰC KỲ QUAN TRỌNG)
          if (!_taskLoaded) {
            context.read<TaskBloc>().add(
              LoadTasks(userId),
            );
            _taskLoaded = true;
          }
        }

        // 🔄 RESET KHI LOGOUT
        if (authState is AuthUnauthenticated) {
          _categoryLoaded = false;
          _taskLoaded = false;
        }
      },
      child: Scaffold(
        // ================= APP BAR =================
        appBar: AppBar(
          title: Text(_titleByIndex(_currentIndex)),
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          actions: [
            // ➕ ADD TASK
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddTaskPage(),
                  ),
                );
              },
            ),

            // ⋮ LOGOUT
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'logout') {
                  context.read<AuthBloc>().add(SignOutRequested());
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Logout'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),

        // ================= DRAWER =================
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(color: Colors.green),
                child: Text(
                  'Task Manager',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
              _drawerItem(Icons.list, 'To do tasks', 1),
              _drawerItem(Icons.check_circle, 'Completed tasks', 2),
              _drawerItem(Icons.cancel, 'Missed tasks', 3),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Profile'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ProfilePage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),

        // ================= BODY =================
        body: _pages[_currentIndex],

        // ================= BOTTOM NAV =================
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.list), label: 'To do'),
            BottomNavigationBarItem(
                icon: Icon(Icons.check), label: 'Completed'),
            BottomNavigationBarItem(
                icon: Icon(Icons.cancel), label: 'Missed'),
          ],
        ),
      ),
    );
  }

  String _titleByIndex(int index) {
    switch (index) {
      case 0:
        return 'Home';
      case 1:
        return 'To do';
      case 2:
        return 'Completed';
      case 3:
        return 'Missed';
      default:
        return '';
    }
  }

  ListTile _drawerItem(IconData icon, String title, int index) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        setState(() => _currentIndex = index);
        Navigator.pop(context);
      },
    );
  }
}
