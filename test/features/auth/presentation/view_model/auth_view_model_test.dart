import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrisphere_flutter/core/error/failures.dart';
import 'package:nutrisphere_flutter/features/auth/domain/entities/auth_entity.dart';
import 'package:nutrisphere_flutter/features/auth/domain/repositories/auth_repository.dart';
import 'package:nutrisphere_flutter/features/auth/domain/usecases/login_usecase.dart';
import 'package:nutrisphere_flutter/features/auth/domain/usecases/register_usecase.dart';
import 'package:nutrisphere_flutter/features/auth/presentation/state/auth_state.dart';
import 'package:nutrisphere_flutter/features/auth/presentation/view_model/auth_view_model.dart';

class _FakeAuthRepository implements IAuthRepository {
  _FakeAuthRepository({required this.loginResult, required this.registerResult});

  final Either<Failure, AuthEntity> loginResult;
  final Either<Failure, bool> registerResult;

  @override
  Future<Either<Failure, AuthEntity>> login(String email, String password) async => loginResult;

  @override
  Future<Either<Failure, bool>> register(AuthEntity entity) async => registerResult;

  @override
  Future<Either<Failure, AuthEntity>> getCurrentUser() => throw UnimplementedError();
  @override
  Future<Either<Failure, void>> logout() => throw UnimplementedError();
  @override
  Future<Either<Failure, AuthEntity>> updateUser(AuthEntity user) => throw UnimplementedError();
}

void main() {
  ProviderContainer createContainer({required IAuthRepository repo}) {
    final register = RegisterUsecase(authRepository: repo);
    final login = LoginUsecase(authRepository: repo);
    return ProviderContainer(overrides: [
      registerUseCaseProvider.overrideWithValue(register),
      loginUseCaseProvider.overrideWithValue(login),
    ]);
  }

  group('AuthViewModel', () {
    test('starts with initial state', () {
      final container = createContainer(
        repo: _FakeAuthRepository(loginResult: const Left(ApiFailure(message: 'x')), registerResult: const Right(true)),
      );

      final state = container.read(authViewModelProvider);

      expect(state.status, AuthStatus.initial);
    });

    test('register sets authenticated on success', () async {
      final container = createContainer(
        repo: _FakeAuthRepository(loginResult: const Left(ApiFailure(message: 'x')), registerResult: const Right(true)),
      );

      await container.read(authViewModelProvider.notifier).register(
            fullName: 'User',
            email: 'u@mail.com',
            password: '1234',
            confirmPassword: '1234',
          );

      expect(container.read(authViewModelProvider).status, AuthStatus.authenticated);
    });

    test('register sets error on failure', () async {
      final container = createContainer(
        repo: _FakeAuthRepository(
          loginResult: const Left(ApiFailure(message: 'x')),
          registerResult: const Left(ApiFailure(message: 'bad register')),
        ),
      );

      await container.read(authViewModelProvider.notifier).register(
            fullName: 'User',
            email: 'u@mail.com',
            password: '1234',
            confirmPassword: '1234',
          );

      expect(container.read(authViewModelProvider).status, AuthStatus.error);
    });

    test('login sets authenticated on success', () async {
      final user = const AuthEntity(fullName: 'User', email: 'u@mail.com');
      final container = createContainer(
        repo: _FakeAuthRepository(loginResult: Right(user), registerResult: const Right(true)),
      );

      await container.read(authViewModelProvider.notifier).login(email: 'u@mail.com', password: '1234');

      expect(container.read(authViewModelProvider).authEntity?.email, 'u@mail.com');
    });
  });
}