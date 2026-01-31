import 'dart:io';
import '../task/task_history_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/theme/theme_cubit.dart';

import '../../../core/services/avatar_upload_service.dart';
import '../../../core/services/image_pick_and_crop_service.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/services/notification_permission_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _uploading = false;

  Future<void> _changeAvatar() async {
    final File? file =
    await ImagePickAndCropService.pickAndCropAvatar(context);

    if (file == null) return;

    setState(() => _uploading = true);

    try {
      final url = await AvatarUploadService.upload(file);

      if (!mounted) return;

      context.read<AuthBloc>().add(
        UpdateAvatarRequested(url),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! AuthAuthenticated) {
          return const Scaffold(
            body: Center(child: Text('Not logged in')),
          );
        }

        final user = state.user;

        return Scaffold(
          appBar: AppBar(title: const Text('Profile')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              /// 👤 AVATAR
              Center(
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        CircleAvatar(
                          radius: 48,
                          backgroundImage: user.avatarUrl != null
                              ? NetworkImage(user.avatarUrl!)
                              : null,
                          child: user.avatarUrl == null
                              ? const Icon(Icons.person, size: 48)
                              : null,
                        ),
                        if (_uploading)
                          Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.4),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: _uploading ? null : _changeAvatar,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Change avatar'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              /// 👤 INFO
              ListTile(
                leading: const Icon(Icons.person),
                title: Text(user.username),
                subtitle: Text(user.email),
              ),

              const Divider(),

              /// 🌗 THEME
              SwitchListTile(
                title: const Text('Dark mode'),
                secondary: const Icon(Icons.dark_mode),
                value: context.watch<ThemeCubit>().state == ThemeMode.dark,
                onChanged: (v) {
                  final cubit = context.read<ThemeCubit>();
                  v ? cubit.setDark() : cubit.setLight();
                },
              ),

              const Divider(),

              /// 🔔 REMINDER PERMISSION
              ListTile(
                leading: const Icon(Icons.notifications_active),
                title: const Text('Enable reminders'),
                subtitle:
                const Text('Allow notifications for task deadlines'),
                onTap: () async {
                  final granted =
                  await NotificationPermissionService.requestAll();

                  if (!mounted) return;

                  if (!granted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                        Text('Notification permission was denied'),
                      ),
                    );
                    return;
                  }

                  await NotificationService.sendTestNotification();

                  if (!mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Reminder enabled successfully'),
                    ),
                  );
                },
              ),

              const Divider(),

              /// 📜 HISTORY
              ListTile(
                leading: const Icon(Icons.history),
                title: const Text('Task history'),
                subtitle:
                const Text('Created, completed & missed tasks'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TaskHistoryPage(),
                    ),
                  );
                },

              ),

              /// ❓ GUIDE
              ListTile(
                leading: const Icon(Icons.help_outline),
                title: const Text('User guide'),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('How to use'),
                      content: const Text(
                        '• Create tasks\n'
                            '• Set due date\n'
                            '• Complete or edit tasks\n'
                            '• Track progress on Home',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('OK'),
                        )
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
