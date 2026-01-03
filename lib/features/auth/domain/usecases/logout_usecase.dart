import 'package:dartz/dartz.dart';
import 'package:nutrisphere_flutter/core/error/failures.dart';
import 'package:nutrisphere_flutter/core/usecase/usecase.dart';
import 'package:nutrisphere_flutter/features/auth/domain/repositories/auth_repository.dart';

class LogoutUsecase implements UsecaseWithoutParms<void> {
  final IAuthRepository _authRepository;

  LogoutUsecase({required IAuthRepository authRepository})
      : _authRepository = authRepository;

  @override
  Future<Either<Failure, void>> call() {
    return _authRepository.logout();
  }
}
