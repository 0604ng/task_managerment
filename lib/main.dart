import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';
import 'const/theme.dart';

// DATA SOURCES
import 'data/datasources/auth_remote_data_source.dart';
import 'data/datasources/task_remote_data_source.dart';

// REPOSITORIES
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/task_repository_impl.dart';

// AUTH USECASES
import 'domain/usecases/auth/sign_in_usecase.dart';
import 'domain/usecases/auth/sign_up_usecase.dart';
import 'domain/usecases/auth/sign_out_usecase.dart';
import 'domain/usecases/auth/watch_auth_state_usecase.dart';

// TASK USECASES
import 'domain/usecases/task/get_tasks_usecase.dart';
import 'domain/usecases/task/get_tasks_by_category_usecase.dart';
import 'domain/usecases/task/create_task_usecase.dart';
import 'domain/usecases/task/update_task_usecase.dart';
import 'domain/usecases/task/delete_task_usecase.dart';

// BLOCS
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/auth/auth_event.dart';
import 'presentation/blocs/task/task_bloc.dart';

// MAIN SCREEN
import 'screen/auth_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final firebaseAuth = FirebaseAuth.instance;

  // AUTH datasource + repo
  final authRemoteDataSource = AuthRemoteDataSourceImpl(firebaseAuth);
  final authRepository = AuthRepositoryImpl(authRemoteDataSource);

  // TASK datasource + repo
  final taskRemoteDataSource = TaskRemoteDataSourceImpl(
    FirebaseFirestore.instance,
    FirebaseAuth.instance,
  );

  final taskRepository = TaskRepositoryImpl(taskRemoteDataSource);

  runApp(
    MultiBlocProvider(
      providers: [
        // AUTH BLOC
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc(
            signInUseCase: SignInUseCase(authRepository),
            signUpUseCase: SignUpUseCase(authRepository),
            signOutUseCase: SignOutUseCase(authRepository),
            watchAuthStateUseCase: WatchAuthStateUseCase(authRepository),
          )..add(WatchAuthStateRequested()),
        ),

        // TASK BLOC
        BlocProvider<TaskBloc>(
          create: (_) => TaskBloc(
            getTasksUseCase: GetTasksUseCase(taskRepository),
            getTasksByCategoryUseCase: GetTasksByCategoryUseCase(taskRepository),
            createTaskUseCase: CreateTaskUseCase(taskRepository),
            updateTaskUseCase: UpdateTaskUseCase(taskRepository),
            deleteTaskUseCase: DeleteTaskUseCase(taskRepository),
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
    return MaterialApp(
      title: 'Task Manager',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      home: const AuthGate(),
    );
  }
}