import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrisphere_flutter/core/error/failures.dart';
import 'package:nutrisphere_flutter/features/auth/domain/entities/auth_entity.dart';
import 'package:nutrisphere_flutter/features/auth/domain/repositories/auth_repository.dart';
import 'package:nutrisphere_flutter/features/auth/domain/usecases/update_user_usecase.dart';

class _FakeAuthRepository implements IAuthRepository {
  AuthEntity? updated;

  @override
  Future<Either<Failure, AuthEntity>> updateUser(AuthEntity user) async {
    updated = user;
    return Right(user);
  }

  @override
  Future<Either<Failure, AuthEntity>> getCurrentUser() => throw UnimplementedError();

  @override
  Future<Either<Failure, AuthEntity>> login(String email, String password) => throw UnimplementedError();

  @override
  Future<Either<Failure, void>> logout() => throw UnimplementedError();

  @override
  Future<Either<Failure, bool>> register(AuthEntity entity) => throw UnimplementedError();
}

void main() {
  test('UpdateUserUsecase forwards entity to repository', () async {
    final repo = _FakeAuthRepository();
    final usecase = UpdateUserUsecase(authRepository: repo);
    const user = AuthEntity(fullName: 'Updated', email: 'u@mail.com');

    final result = await usecase(const UpdateUserUsecaseParams(user: user));

    expect(result, const Right(user));
    expect(repo.updated?.fullName, 'Updated');
  });
}