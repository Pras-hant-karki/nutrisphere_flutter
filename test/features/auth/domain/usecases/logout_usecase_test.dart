import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrisphere_flutter/core/error/failures.dart';
import 'package:nutrisphere_flutter/features/auth/domain/entities/auth_entity.dart';
import 'package:nutrisphere_flutter/features/auth/domain/repositories/auth_repository.dart';
import 'package:nutrisphere_flutter/features/auth/domain/usecases/logout_usecase.dart';

class _FakeAuthRepository implements IAuthRepository {
  @override
  Future<Either<Failure, void>> logout() async => const Right(null);

  @override
  Future<Either<Failure, AuthEntity>> getCurrentUser() => throw UnimplementedError();

  @override
  Future<Either<Failure, AuthEntity>> login(String email, String password) => throw UnimplementedError();

  @override
  Future<Either<Failure, bool>> register(AuthEntity entity) => throw UnimplementedError();

  @override
  Future<Either<Failure, AuthEntity>> updateUser(AuthEntity user) => throw UnimplementedError();
}

void main() {
  test('LogoutUsecase calls repository logout', () async {
    final usecase = LogoutUsecase(authRepository: _FakeAuthRepository());

    final result = await usecase();

    expect(result, const Right(null));
  });
}