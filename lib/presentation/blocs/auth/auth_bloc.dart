import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import '../../../domain/usecases/auth/reset_password_usecase.dart';

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
  final ResetPasswordUseCase resetPasswordUseCase;

  StreamSubscription<UserEntity?>? _authStateSubscription;

  AuthBloc({
    required this.signInUseCase,
    required this.signUpUseCase,
    required this.signOutUseCase,
    required this.watchAuthStateUseCase,
    required this.resetPasswordUseCase,
  }) : super(AuthInitial()) {

    /// LOGIN
    on<SignInRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await signInUseCase(event.email, event.password);
        // ❌ KHÔNG emit AuthAuthenticated ở đây
        // Firebase authStateChanges sẽ xử lý
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });


    /// SIGNUP
    on<SignUpRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await signUpUseCase(
          event.email,
          event.password,
          event.username,
        );
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
    on<ResetPasswordRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await resetPasswordUseCase(event.email);
        emit(PasswordResetEmailSent());
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

  }

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }
}