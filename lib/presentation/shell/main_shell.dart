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

import '../../../const/colors.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  bool _categoryLoaded = false;
  bool _taskLoaded = false;

  final List<Widget> _pages = const [
    HomePage(),       // 0
    TodoPage(),       // 1
    CompletedPage(),  // 2
    MissedPage(),     // 3
    ProfilePage(),    // 4
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
          title: Text(
            _titleByIndex(_currentIndex),
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
              fontSize: 22,
            ),
          ),
          leading: Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.menu_open_rounded, color: isDark ? Colors.white : AppColors.textPrimary, size: 28),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.border,
                  width: 1,
                ),
              ),
              child: IconButton(
                icon: const Icon(Icons.add_rounded, color: AppColors.primary, size: 24),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AddTaskPage(),
                    ),
                  );
                },
              ),
            ),
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert_rounded, color: isDark ? Colors.white : AppColors.textPrimary),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              onSelected: (value) {
                if (value == 'logout') {
                  context.read<AuthBloc>().add(SignOutRequested());
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout_rounded, color: theme.colorScheme.error, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        'Logout',
                        style: TextStyle(
                          color: theme.colorScheme.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),

        // ================= DRAWER =================
        drawer: Drawer(
          backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
          child: SafeArea(
            child: Column(
              children: [
                /// 👤 USER HEADER (DYNAMC & LUXURIOUS)
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    if (state is! AuthAuthenticated) {
                      return const SizedBox.shrink();
                    }

                    final user = state.user;

                    return Container(
                      width: double.infinity,
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.secondary],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.15),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: CircleAvatar(
                                  radius: 30,
                                  backgroundColor: Colors.white,
                                  backgroundImage: user.avatarUrl != null
                                      ? NetworkImage(user.avatarUrl!)
                                      : null,
                                  child: user.avatarUrl == null
                                      ? const Icon(
                                          Icons.person_rounded,
                                          size: 32,
                                          color: AppColors.primary,
                                        )
                                      : null,
                                ),
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: () {
                                  setState(() => _currentIndex = 4);
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'Edit Profile',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            user.username,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.2,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user.email,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    );
                  },
                ),

                /// 📋 MENU (SPACIOUS & BEAUTIFULLY HIGHLIGHTED)
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    children: [
                      _drawerItem(Icons.dashboard_rounded, 'Dashboard', 0),
                      _drawerItem(Icons.assignment_rounded, 'To-Do Tasks', 1),
                      _drawerItem(Icons.check_circle_rounded, 'Completed Tasks', 2),
                      _drawerItem(Icons.watch_later_rounded, 'Missed Tasks', 3),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Divider(color: AppColors.border, thickness: 1),
                      ),
                      _drawerItem(Icons.account_circle_rounded, 'My Profile', 4),
                    ],
                  ),
                ),

                /// 🚪 LOGOUT (BOTTOM DOCK)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : AppColors.border,
                        width: 1,
                      ),
                    ),
                    child: ListTile(
                      leading: Icon(Icons.logout_rounded, color: theme.colorScheme.error),
                      title: Text(
                        'Logout Account',
                        style: TextStyle(
                          color: theme.colorScheme.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      onTap: () {
                        context.read<AuthBloc>().add(SignOutRequested());
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // ================= BODY =================
        body: _pages[_currentIndex],

        // ================= BOTTOM NAV (FLOATING DOCK) =================
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 20, top: 8),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BottomNavigationBar(
                currentIndex: _currentIndex > 3 ? 0 : _currentIndex,
                onTap: (index) => setState(() => _currentIndex = index),
                type: BottomNavigationBarType.fixed,
                backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
                selectedItemColor: AppColors.primary,
                unselectedItemColor: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                showSelectedLabels: true,
                showUnselectedLabels: false,
                elevation: 0,
                selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                items: const [
                  BottomNavigationBarItem(
                      icon: Icon(Icons.dashboard_rounded), label: 'Home'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.assignment_rounded), label: 'To do'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.check_circle_rounded), label: 'Completed'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.watch_later_rounded), label: 'Missed'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _titleByIndex(int index) {
    switch (index) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'To-Do Tasks';
      case 2:
        return 'Completed Tasks';
      case 3:
        return 'Missed Tasks';
      case 4:
        return 'User Profile';
      default:
        return '';
    }
  }

  Widget _drawerItem(IconData icon, String title, int index) {
    final theme = Theme.of(context);
    final isSelected = _currentIndex == index;
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected
              ? Colors.white
              : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected
                ? Colors.white
                : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
          ),
        ),
        selected: isSelected,
        selectedTileColor: AppColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onTap: () {
          setState(() => _currentIndex = index);
          Navigator.pop(context);
        },
      ),
    );
  }
}
