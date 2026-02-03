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
  bool _taskLoaded = false;

  /// 🌟 TẤT CẢ PAGE ĐI QUA ĐÂY
  final List<Widget> _pages = const [
    HomePage(),       // 0
    TodoPage(),       // 1
    CompletedPage(),  // 2
    MissedPage(),     // 3
    ProfilePage(),    // 4 ⭐
  ];

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, authState) {
        if (authState is AuthAuthenticated) {
          final userId = authState.user.id;

          if (!_categoryLoaded) {
            context.read<CategoryBloc>().add(LoadCategories(userId));
            _categoryLoaded = true;
          }

          if (!_taskLoaded) {
            context.read<TaskBloc>().add(LoadTasks(userId));
            _taskLoaded = true;
          }
        }

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
          child: SafeArea(
            child: Column(
              children: [
                /// 👤 USER HEADER (DYNAMIC)
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    if (state is! AuthAuthenticated) {
                      return const SizedBox.shrink();
                    }

                    final user = state.user;

                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 20,
                      ),
                      decoration: const BoxDecoration(
                        color: Colors.green,
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 32,
                            backgroundColor: Colors.white,
                            backgroundImage: user.avatarUrl != null
                                ? NetworkImage(user.avatarUrl!)
                                : null,
                            child: user.avatarUrl == null
                                ? const Icon(
                              Icons.person,
                              size: 32,
                              color: Colors.green,
                            )
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.username,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  user.email,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                /// 📋 MENU
                Expanded(
                  child: ListView(
                    children: [
                      _drawerItem(Icons.home, 'Home', 0),
                      _drawerItem(Icons.list, 'To do tasks', 1),
                      _drawerItem(Icons.check_circle, 'Completed tasks', 2),
                      _drawerItem(Icons.cancel, 'Missed tasks', 3),

                      const Divider(),

                      _drawerItem(Icons.person, 'Profile', 4),
                    ],
                  ),
                ),

                /// 🚪 LOGOUT (BOTTOM)
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text(
                      'Logout',
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: () {
                      context.read<AuthBloc>().add(SignOutRequested());
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),


        // ================= BODY =================
        body: _pages[_currentIndex],

        // ================= BOTTOM NAV =================
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex > 3 ? 0 : _currentIndex,
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
      case 4:
        return 'Profile';
      default:
        return '';
    }
  }

  ListTile _drawerItem(IconData icon, String title, int index) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      selected: _currentIndex == index,
      onTap: () {
        setState(() => _currentIndex = index);
        Navigator.pop(context);
      },
    );
  }
}
