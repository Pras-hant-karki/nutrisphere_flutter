import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrisphere_flutter/core/error/failures.dart';
import 'package:nutrisphere_flutter/features/auth/domain/entities/auth_entity.dart';
import 'package:nutrisphere_flutter/features/auth/domain/repositories/auth_repository.dart';
import 'package:nutrisphere_flutter/features/auth/domain/usecases/register_usecase.dart';

class _FakeAuthRepository implements IAuthRepository {
  _FakeAuthRepository({this.registerResult});

  final Either<Failure, bool>? registerResult;
  AuthEntity? received;

  @override
  Future<Either<Failure, bool>> register(AuthEntity entity) async {
    received = entity;
    return registerResult!;
  }

  @override
  Future<Either<Failure, AuthEntity>> getCurrentUser() => throw UnimplementedError();

  @override
  Future<Either<Failure, AuthEntity>> login(String email, String password) => throw UnimplementedError();

  @override
  Future<Either<Failure, void>> logout() => throw UnimplementedError();

  @override
  Future<Either<Failure, AuthEntity>> updateUser(AuthEntity user) => throw UnimplementedError();
}

void main() {
  group('RegisterUsecase', () {
    test('maps params and returns success', () async {
      final repo = _FakeAuthRepository(registerResult: const Right(true));
      final usecase = RegisterUsecase(authRepository: repo);

      final result = await usecase(const RegisterUsecaseParams(
        fullName: 'New User',
        email: 'new@mail.com',
        password: '1234',
        confirmPassword: '1234',
      ));

      expect(result, const Right(true));
      expect(repo.received?.email, 'new@mail.com');
    });

  });
}