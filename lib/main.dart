import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'domain/usecases/auth/update_avatar_usecase.dart';
import 'domain/usecases/auth/update_username_usecase.dart';
import 'firebase_options.dart';
import 'const/theme.dart';
import 'core/services/notification_service.dart';

// ================= DATA SOURCES =================
import 'data/datasources/auth_remote_data_source.dart';
import 'data/datasources/task_remote_data_source.dart';
import 'data/datasources/category_remote_data_source.dart';

// ================= REPOSITORIES =================
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/task_repository_impl.dart';
import 'data/repositories/category_repository_impl.dart';

// ================= AUTH USECASES =================
import 'domain/usecases/auth/sign_in_usecase.dart';
import 'domain/usecases/auth/sign_up_usecase.dart';
import 'domain/usecases/auth/sign_out_usecase.dart';
import 'domain/usecases/auth/watch_auth_state_usecase.dart';
import 'domain/usecases/auth/reset_password_usecase.dart';

// ================= TASK USECASES =================
import 'domain/usecases/task/get_tasks_usecase.dart';
import 'domain/usecases/task/get_tasks_by_category_usecase.dart';
import 'domain/usecases/task/create_task_usecase.dart';
import 'domain/usecases/task/update_task_usecase.dart';
import 'domain/usecases/task/delete_task_usecase.dart';
import 'domain/usecases/task/reassign_tasks_usecase.dart';
import 'domain/usecases/task/delete_tasks_by_category_usecase.dart';

// ================= CATEGORY USECASES =================
import 'domain/usecases/category/get_categories_by_user_usecase.dart';
import 'domain/usecases/category/create_category_usecase.dart';
import 'domain/usecases/category/update_category_usecase.dart';
import 'domain/usecases/category/delete_category_usecase.dart';

// ================= BLOCS =================
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/auth/auth_event.dart';
import 'presentation/blocs/task/task_bloc.dart';
import 'presentation/blocs/category/category_bloc.dart';
import 'presentation/blocs/theme/theme_cubit.dart';

// ================= ENTRY =================
import 'presentation/pages/auth/auth_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await NotificationService.init();
  final firebaseAuth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;

  final authRepository =
  AuthRepositoryImpl(AuthRemoteDataSourceImpl(firebaseAuth));
  final taskRepository = TaskRepositoryImpl(
      TaskRemoteDataSourceImpl(firestore, firebaseAuth));
  final categoryRepository = CategoryRepositoryImpl(
      CategoryRemoteDataSourceImpl(firestore, firebaseAuth));

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit()),

        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc(
            signInUseCase: SignInUseCase(authRepository),
            signUpUseCase: SignUpUseCase(authRepository),
            signOutUseCase: SignOutUseCase(authRepository),
            watchAuthStateUseCase:
            WatchAuthStateUseCase(authRepository),
            resetPasswordUseCase:
            ResetPasswordUseCase(authRepository),

            updateAvatarUseCase: // 🔥 ADD
            UpdateAvatarUseCase(authRepository),
            updateUsernameUseCase:
            UpdateUsernameUseCase(authRepository),
          )..add(WatchAuthStateRequested()),
        ),


        BlocProvider<TaskBloc>(
          create: (_) => TaskBloc(
            getTasksUseCase: GetTasksUseCase(taskRepository),
            getTasksByCategoryUseCase:
            GetTasksByCategoryUseCase(taskRepository),
            createTaskUseCase:
            CreateTaskUseCase(taskRepository),
            updateTaskUseCase:
            UpdateTaskUseCase(taskRepository),
            deleteTaskUseCase:
            DeleteTaskUseCase(taskRepository),
          ),
        ),

        BlocProvider<CategoryBloc>(
          create: (_) => CategoryBloc(
            createCategoryUseCase:
            CreateCategoryUseCase(categoryRepository),
            updateCategoryUseCase:
            UpdateCategoryUseCase(categoryRepository),
            deleteCategoryUseCase:
            DeleteCategoryUseCase(categoryRepository),
            getCategoriesByUserUseCase:
            GetCategoriesByUserUseCase(categoryRepository),
            reassignTasksUseCase:
            ReassignTasksUseCase(taskRepository),
            deleteTasksByCategoryUseCase:
            DeleteTasksByCategoryUseCase(taskRepository),
          ),
        ),
      ],
      child: const TaskManagerApp(),
    ),
  );
}

class TaskManagerApp extends StatelessWidget {
  const TaskManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        return MaterialApp(
          title: 'Task Manager',
          debugShowCheckedModeBanner: false,
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeMode,
          home: const AuthGate(),
        );
      },
    );
  }
}
