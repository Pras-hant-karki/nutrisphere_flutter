import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutrisphere_flutter/features/auth/domain/entities/auth_entity.dart';
import 'package:nutrisphere_flutter/features/auth/domain/usecases/login_usecase.dart';
import 'package:nutrisphere_flutter/features/auth/domain/usecases/register_usecase.dart';
import 'package:nutrisphere_flutter/features/auth/presentation/state/auth_state.dart';

// provider
final authViewModelProvider =
    NotifierProvider<AuthViewModel, AuthState>(() => 
    AuthViewModel()); // NotifierProvider

class AuthViewModel extends Notifier<AuthState> {
  late final RegisterUsecase _registerUsecase;
  late final LoginUsecase _loginUsecase;

  @override
  AuthState build() {
    _registerUsecase = ref.read(registerUseCaseProvider);
    _loginUsecase = ref.read(loginUseCaseProvider);
    return const AuthState();
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);
    // wait for 2 sec
    await Future.delayed(const Duration(seconds: 2));
    final params = RegisterUsecaseParams(
      fullName: fullName,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
    );
    final result = await _registerUsecase(params);
    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
      },
      (isRegistered) {
        // After successful registration, create a temporary user entity for display
        if (isRegistered) {
          final tempUser = AuthEntity(
            fullName: fullName,
            email: email,
            password: password,
          );
          // Set authenticated status - token is already saved in secure storage
          state = state.copyWith(
            status: AuthStatus.authenticated,
            authEntity: tempUser,
          );
        }
      },
    );
  }

// login
  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);
    await Future.delayed(const Duration(seconds: 2));
    final params = LoginUsecaseParams(
      email: email,
      password: password,
    );
    final result = await _loginUsecase(params);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
      },
      (authEntity) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          authEntity: authEntity,
        );
      },
    );
  }
  
}