import 'dart:io';
import '../task/task_history_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/theme/theme_cubit.dart';
import '../../../const/colors.dart';

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
  TextEditingController? _usernameCtrl;
  bool _savingUsername = false;
  bool _remindersEnabled = false;
  bool _isEditingName = false;

  @override
  void initState() {
    super.initState();
    _checkReminderStatus();
  }

  Future<void> _checkReminderStatus() async {
    final enabled = await NotificationPermissionService.isGranted();
    if (mounted) {
      setState(() => _remindersEnabled = enabled);
    }
  }

  @override
  void dispose() {
    _usernameCtrl?.dispose();
    super.dispose();
  }

  Future<void> _changeAvatar() async {
    final File? file =
    await ImagePickService.pickAvatar();

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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! AuthAuthenticated) {
          return const Scaffold(
            body: Center(child: Text('Not logged in')),
          );
        }

        final user = state.user;
        _usernameCtrl ??= TextEditingController(text: user.username);

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

              /// 👤 EDITABLE PROFILE INFO CARD
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.border,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.person_rounded, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Text(
                              'Profile Identity',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        if (!_isEditingName)
                          IconButton(
                            icon: const Icon(Icons.edit_rounded, color: AppColors.primary, size: 20),
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () {
                              setState(() {
                                _isEditingName = true;
                                _usernameCtrl?.text = user.username;
                              });
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (!_isEditingName) ...[
                      // READ-ONLY DISPLAY STATE
                      Text(
                        user.username,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Email: ${user.email}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        ),
                      ),
                    ] else ...[
                      // ACTIVE EDITING STATE
                      TextFormField(
                        controller: _usernameCtrl,
                        decoration: InputDecoration(
                          labelText: "Display Name",
                          prefixIcon: const Icon(Icons.badge_rounded, color: AppColors.primary),
                          fillColor: isDark ? AppColors.darkBackground : AppColors.background,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Email: ${user.email}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          // Cancel Button
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.border),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              onPressed: _savingUsername
                                  ? null
                                  : () {
                                      setState(() => _isEditingName = false);
                                    },
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Save Button
                          Expanded(
                            flex: 2,
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [AppColors.primary, AppColors.secondary],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                onPressed: _savingUsername
                                    ? null
                                    : () async {
                                        final newName = _usernameCtrl!.text.trim();
                                        if (newName.isEmpty) return;

                                        setState(() => _savingUsername = true);
                                        context.read<AuthBloc>().add(
                                              UpdateUsernameRequested(newName),
                                            );
                                        
                                        await Future.delayed(const Duration(milliseconds: 500));
                                        if (context.mounted) {
                                          setState(() {
                                            _savingUsername = false;
                                            _isEditingName = false; // Collapse editing mode
                                          });
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: const Text('Display name updated successfully!'),
                                              backgroundColor: AppColors.success,
                                              behavior: SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                            ),
                                          );
                                        }
                                      },
                                child: _savingUsername
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                    : const Text(
                                        'Save Name',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
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

              /// 🔔 REMINDER & NOTIFICATION SETTINGS CARD
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.border,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    // Bell Icon with glow
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _remindersEnabled
                            ? AppColors.primary.withValues(alpha: 0.15)
                            : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03)),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _remindersEnabled ? Icons.notifications_active_rounded : Icons.notifications_off_rounded,
                        color: _remindersEnabled ? AppColors.primary : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Task Reminders',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Custom tag pill
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _remindersEnabled
                                      ? AppColors.success.withValues(alpha: 0.15)
                                      : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05)),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  _remindersEnabled ? 'ACTIVE' : 'OFF',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    color: _remindersEnabled ? AppColors.success : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Allow notifications for task deadlines',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Switch
                     Switch(
                       activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
                       activeThumbColor: AppColors.primary,
                       value: _remindersEnabled,
                      onChanged: (v) async {
                        if (v) {
                          final granted = await NotificationPermissionService.requestAll();
                          if (!context.mounted) return;

                          if (!granted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Notification permission was denied. Please enable it in Settings.'),
                                backgroundColor: AppColors.error,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            );
                            setState(() => _remindersEnabled = false);
                            return;
                          }

                          await NotificationService.sendTestNotification();
                          if (!context.mounted) return;

                          setState(() => _remindersEnabled = true);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Reminders enabled with a test notification!'),
                              backgroundColor: AppColors.success,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          );
                        } else {
                          // Toggling off in-app
                          setState(() => _remindersEnabled = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Reminders disabled in-app. Revoke permissions in System Settings to disable fully.'),
                              backgroundColor: AppColors.warning,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
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
