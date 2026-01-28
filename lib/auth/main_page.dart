// lib/auth/main_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/auth_data.dart';
import 'package:task_manager/presentation/pages/main/home_page.dart';
import '../const/colors.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthData>(context, listen: false);
    final user = auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Tasks • ${user?.email ?? ''}'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(user?.email?.split('@').first ?? 'User'),
              accountEmail: Text(user?.email ?? ''),
              currentAccountPicture: CircleAvatar(child: Text((user?.email ?? 'U').substring(0,1).toUpperCase())),
              decoration: const BoxDecoration(color: AppColors.primary),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                // TODO: navigation to settings
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Sign out'),
              onTap: () async {
                await auth.signOut();
              },
            ),
          ],
        ),
      ),
      body: const HomePage(),
    );
  }
}
