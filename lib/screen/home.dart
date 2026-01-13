import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../const/colors.dart';
import '../presentation/blocs/auth/auth_bloc.dart';
import '../presentation/blocs/auth/auth_event.dart';
import '../presentation/blocs/auth/auth_state.dart';
import 'task_list_page.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (ctx, state) {
        if (state is! AuthAuthenticated) {
          return const Scaffold(
            body: Center(child: Text("Not logged in")),
          );
        }

        final user = state.user;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text("Welcome, ${user.username} 👋"),
            actions: [
              IconButton(
                tooltip: 'Logout',
                icon: const Icon(Icons.logout),
                onPressed: () {
                  context
                      .read<AuthBloc>()
                      .add(SignOutRequested());
                },
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 10,
            ),
            child: ListView(
              children: [
                const SizedBox(height: 8),
                Text(
                  'Today',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TaskListPage(user: user),
                ),
              );
            },
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}
