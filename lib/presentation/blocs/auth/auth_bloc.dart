import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';

import '../../../domain/entity/user_entity.dart';
import '../../../domain/usecases/auth/sign_in_usecase.dart';
import '../../../domain/usecases/auth/sign_up_usecase.dart';
import '../../../domain/usecases/auth/sign_out_usecase.dart';
import '../../../domain/usecases/auth/watch_auth_state_usecase.dart';
import '../../../domain/usecases/auth/reset_password_usecase.dart';
import '../../../domain/usecases/auth/update_avatar_usecase.dart'; // 🔥 ADD
import '../../../domain/usecases/auth/update_username_usecase.dart';

import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInUseCase signInUseCase;
  final SignUpUseCase signUpUseCase;
  final SignOutUseCase signOutUseCase;
  final WatchAuthStateUseCase watchAuthStateUseCase;
  final ResetPasswordUseCase resetPasswordUseCase;
  final UpdateAvatarUseCase updateAvatarUseCase; // 🔥 ADD
  final UpdateUsernameUseCase updateUsernameUseCase;

  StreamSubscription<UserEntity?>? _authStateSubscription;

  AuthBloc({
    required this.signInUseCase,
    required this.signUpUseCase,
    required this.signOutUseCase,
    required this.watchAuthStateUseCase,
    required this.resetPasswordUseCase,
    required this.updateAvatarUseCase, // 🔥 ADD
    required this.updateUsernameUseCase,
  }) : super(AuthInitial()) {

    /// LOGIN
    on<SignInRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await signInUseCase(event.email, event.password);
        if (user != null) {
          emit(AuthAuthenticated(user));
        } else {
          emit(AuthUnauthenticated());
        }
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    /// SIGNUP
    on<SignUpRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await signUpUseCase(
          event.email,
          event.password,
          event.username,
        );
        if (user != null) {
          emit(AuthAuthenticated(user));
        } else {
          emit(AuthUnauthenticated());
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

    /// WATCH AUTH STATE
    on<WatchAuthStateRequested>((event, emit) async {
      emit(AuthLoading());

      await emit.forEach<UserEntity?>(
        watchAuthStateUseCase(),
        onData: (user) {
          if (user == null) return AuthUnauthenticated();
          return AuthAuthenticated(user);
        },
        onError: (error, _) => AuthError(error.toString()),
      );
    });

    /// RESET PASSWORD
    on<ResetPasswordRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await resetPasswordUseCase(event.email);
        emit(PasswordResetEmailSent());
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    /// 🔥 UPDATE AVATAR (NEW)
    on<UpdateAvatarRequested>((event, emit) async {
      if (state is! AuthAuthenticated) return;

      final current = state as AuthAuthenticated;

      try {
        await updateAvatarUseCase(event.avatarUrl);

        emit(
          AuthAuthenticated(
            current.user.copyWith(
              avatarUrl: event.avatarUrl,
            ),
          ),
        );
      } catch (e) {
        // Keep the user authenticated on error to avoid logging them out
        emit(current);
      }
    });

    /// 🔥 UPDATE USERNAME
    on<UpdateUsernameRequested>((event, emit) async {
      if (state is! AuthAuthenticated) return;

      final current = state as AuthAuthenticated;

      try {
        await updateUsernameUseCase(event.username);

        emit(
          AuthAuthenticated(
            current.user.copyWith(
              username: event.username,
            ),
          ),
        );
      } catch (e) {
        // Keep the user authenticated on error to avoid logging them out
        emit(current);
      }
    });
  }

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }
}
