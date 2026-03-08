import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrisphere_flutter/core/error/failures.dart';
import 'package:nutrisphere_flutter/features/fitness/domain/entities/fitness_entity.dart';
import 'package:nutrisphere_flutter/features/fitness/domain/repositories/fitness_repository.dart';
import 'package:nutrisphere_flutter/features/fitness/domain/usecases/get_all_fitness_usecase.dart';

class _FakeFitnessRepository implements IFitnessRepository {
  @override
  Future<Either<Failure, List<FitnessEntity>>> getAllFitness() async {
    return const Right([FitnessEntity(fitnessId: '1', title: 'Yoga')]);
  }

  @override
  Future<Either<Failure, bool>> createFitness(FitnessEntity fitness) => throw UnimplementedError();
  @override
  Future<Either<Failure, bool>> deleteFitness(String fitnessId) => throw UnimplementedError();
  @override
  Future<Either<Failure, List<FitnessEntity>>> getFitnessByCategory(String categoryId) => throw UnimplementedError();
  @override
  Future<Either<Failure, FitnessEntity>> getFitnessById(String fitnessId) => throw UnimplementedError();
  @override
  Future<Either<Failure, String>> uploadPhoto(File photo) => throw UnimplementedError();
  @override
  Future<Either<Failure, String>> uploadVideo(File video) => throw UnimplementedError();
  @override
  Future<Either<Failure, bool>> updateFitness(FitnessEntity fitness) => throw UnimplementedError();
}

void main() {
  test('GetAllFitnessUsecase returns fitness list', () async {
    final usecase = GetAllFitnessUsecase(fitnessRepository: _FakeFitnessRepository());

    final result = await usecase(const GetAllFitnessParams());

    expect(result.isRight(), isTrue);
  });
}