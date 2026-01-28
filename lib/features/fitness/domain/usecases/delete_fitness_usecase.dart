import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutrisphere_flutter/core/error/failures.dart';
import 'package:nutrisphere_flutter/core/usecase/usecase.dart';
import 'package:nutrisphere_flutter/features/fitness/data/repositories/fitness_repository.dart';
import 'package:nutrisphere_flutter/features/fitness/domain/repositories/fitness_repository.dart';

class DeleteFitnessParams extends Equatable {
  final String fitnessId;

  const DeleteFitnessParams({required this.fitnessId});

  @override
  List<Object?> get props => [fitnessId];
}

final deleteFitnessUsecaseProvider = Provider<DeleteFitnessUsecase>((ref) {
  final fitnessRepository = ref.read(fitnessRepositoryProvider);
  return DeleteFitnessUsecase(fitnessRepository: fitnessRepository);
});

class DeleteFitnessUsecase implements UsecaseWithParms<bool, DeleteFitnessParams> {
  final IFitnessRepository _fitnessRepository;

  DeleteFitnessUsecase({required IFitnessRepository fitnessRepository})
    : _fitnessRepository = fitnessRepository;

  Future<Either<Failure, bool>> call(DeleteFitnessParams params) {
    return _fitnessRepository.deleteFitness(params.fitnessId);
  }
}
