import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutrisphere_flutter/core/error/failures.dart';
import 'package:nutrisphere_flutter/core/usecase/usecase.dart';
import 'package:nutrisphere_flutter/features/auth/data/repositories/auth_repository.dart';
import 'package:nutrisphere_flutter/features/auth/domain/entities/auth_entity.dart';
import 'package:nutrisphere_flutter/features/auth/domain/repositories/auth_repository.dart';

class UpdateUserUsecaseParams extends Equatable {
  final AuthEntity user;

  const UpdateUserUsecaseParams({
    required this.user,
  });

  @override
  List<Object?> get props => [user];
}

// Provider for UpdateUserUsecase
final updateUserUseCaseProvider = Provider<UpdateUserUsecase>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return UpdateUserUsecase(authRepository: authRepository);
});

class UpdateUserUsecase implements UsecaseWithParms<AuthEntity, UpdateUserUsecaseParams> {
  final IAuthRepository _authRepository;

  UpdateUserUsecase({required IAuthRepository authRepository})
      : _authRepository = authRepository;

  @override
  Future<Either<Failure, AuthEntity>> call(UpdateUserUsecaseParams params) {
    return _authRepository.updateUser(params.user);
  }
}