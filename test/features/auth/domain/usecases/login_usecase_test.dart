import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrisphere_flutter/core/error/failures.dart';
import 'package:nutrisphere_flutter/features/auth/domain/entities/auth_entity.dart';
import 'package:nutrisphere_flutter/features/auth/domain/repositories/auth_repository.dart';
import 'package:nutrisphere_flutter/features/auth/domain/usecases/login_usecase.dart';

class _FakeAuthRepository implements IAuthRepository {
  _FakeAuthRepository({this.loginResult});

  final Either<Failure, AuthEntity>? loginResult;
  String? email;
  String? password;

  @override
  Future<Either<Failure, AuthEntity>> login(String email, String password) async {
    this.email = email;
    this.password = password;
    return loginResult!;
  }

  @override
  Future<Either<Failure, AuthEntity>> getCurrentUser() => throw UnimplementedError();

  @override
  Future<Either<Failure, void>> logout() => throw UnimplementedError();

  @override
  Future<Either<Failure, bool>> register(AuthEntity entity) => throw UnimplementedError();

  @override
  Future<Either<Failure, AuthEntity>> updateUser(AuthEntity user) => throw UnimplementedError();
}

void main() {
  group('LoginUsecase', () {
    test('returns user on success', () async {
      final user = const AuthEntity(fullName: 'User', email: 'u@mail.com');
      final repo = _FakeAuthRepository(loginResult: Right(user));
      final usecase = LoginUsecase(authRepository: repo);

      final result = await usecase(const LoginUsecaseParams(email: 'u@mail.com', password: '1234'));

      expect(result, Right(user));
      expect(repo.email, 'u@mail.com');
    });

  });
}