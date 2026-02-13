import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutrisphere_flutter/core/error/failures.dart';
import 'package:nutrisphere_flutter/core/usecase/usecase.dart';
import 'package:nutrisphere_flutter/features/fitness/data/repositories/fitness_repository.dart';
import 'package:nutrisphere_flutter/features/fitness/domain/entities/fitness_entity.dart';
import 'package:nutrisphere_flutter/features/fitness/domain/repositories/fitness_repository.dart';

class GetAllFitnessParams extends Equatable {
  const GetAllFitnessParams();

  @override
  List<Object?> get props => [];
}

// Provider for GetAllFitnessUsecase
final getAllFitnessUsecaseProvider = Provider<GetAllFitnessUsecase>((ref) {
  final fitnessRepository = ref.read(fitnessRepositoryProvider);
  return GetAllFitnessUsecase(fitnessRepository: fitnessRepository);
});

class GetAllFitnessUsecase implements UsecaseWithParms<List<FitnessEntity>, GetAllFitnessParams> {
  final IFitnessRepository _fitnessRepository;

  GetAllFitnessUsecase({required IFitnessRepository fitnessRepository})
      : _fitnessRepository = fitnessRepository;

  @override
  Future<Either<Failure, List<FitnessEntity>>> call(GetAllFitnessParams params) {
    return _fitnessRepository.getAllFitness();
  }
}