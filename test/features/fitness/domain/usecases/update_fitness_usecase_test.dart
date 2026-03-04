import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrisphere_flutter/core/error/failures.dart';
import 'package:nutrisphere_flutter/features/fitness/domain/entities/fitness_entity.dart';
import 'package:nutrisphere_flutter/features/fitness/domain/repositories/fitness_repository.dart';
import 'package:nutrisphere_flutter/features/fitness/domain/usecases/update_fitness_usecase.dart';

class _FakeFitnessRepository implements IFitnessRepository {
  FitnessEntity? updated;

  @override
  Future<Either<Failure, bool>> updateFitness(FitnessEntity fitness) async {
    updated = fitness;
    return const Right(true);
  }

  @override
  Future<Either<Failure, bool>> createFitness(FitnessEntity fitness) => throw UnimplementedError();
  @override
  Future<Either<Failure, bool>> deleteFitness(String fitnessId) => throw UnimplementedError();
  @override
  Future<Either<Failure, List<FitnessEntity>>> getAllFitness() => throw UnimplementedError();
  @override
  Future<Either<Failure, List<FitnessEntity>>> getFitnessByCategory(String categoryId) => throw UnimplementedError();
  @override
  Future<Either<Failure, FitnessEntity>> getFitnessById(String fitnessId) => throw UnimplementedError();
  @override
  Future<Either<Failure, String>> uploadPhoto(File photo) => throw UnimplementedError();
  @override
  Future<Either<Failure, String>> uploadVideo(File video) => throw UnimplementedError();
}

void main() {
  test('UpdateFitnessUsecase maps params and updates repository', () async {
    final repo = _FakeFitnessRepository();
    final usecase = UpdateFitnessUsecase(fitnessRepository: repo);

    final result = await usecase(const UpdateFitnessParams(
      fitnessId: 'f1',
      title: 'Updated',
      location: 'Gym',
    ));

    expect(result, const Right(true));
    expect(repo.updated?.title, 'Updated');
  });
}