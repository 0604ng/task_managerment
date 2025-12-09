import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';

import '../../../domain/entity/user_entity.dart';
import '../../../domain/usecases/auth/sign_in_usecase.dart';
import '../../../domain/usecases/auth/sign_up_usecase.dart';
import '../../../domain/usecases/auth/sign_out_usecase.dart';
import '../../../domain/usecases/auth/watch_auth_state_usecase.dart';

import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInUseCase signInUseCase;
  final SignUpUseCase signUpUseCase;
  final SignOutUseCase signOutUseCase;
  final WatchAuthStateUseCase watchAuthStateUseCase;

  StreamSubscription<UserEntity?>? _authStateSubscription;

  AuthBloc({
    required this.signInUseCase,
    required this.signUpUseCase,
    required this.signOutUseCase,
    required this.watchAuthStateUseCase,
  }) : super(AuthInitial()) {

    /// LOGIN
    on<SignInRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await signInUseCase(event.email, event.password);
        if (user != null) {
          emit(AuthAuthenticated(user));
        } else {
          emit(AuthError("Login failed"));
        }
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    /// SIGNUP
    on<SignUpRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await signUpUseCase(event.email, event.password,
          event.username,);
        if (user != null) {
          emit(AuthAuthenticated(user));
        } else {
          emit(AuthError("Register failed"));
        }
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    /// SIGN OUT
    on<SignOutRequested>((event, emit) async {
      await signOutUseCase();
      emit(AuthUnauthenticated());
    });

    /// WATCH AUTH STATE - THÊM await Ở ĐÂY
    on<WatchAuthStateRequested>((event, emit) async {
      emit(AuthLoading());

      await emit.forEach<UserEntity?>(  // ← THÊM await
        watchAuthStateUseCase(),
        onData: (user) {
          if (user == null) return AuthUnauthenticated();
          return AuthAuthenticated(user);
        },
        onError: (error, _) => AuthError(error.toString()),
      );
    });
  }

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }
}