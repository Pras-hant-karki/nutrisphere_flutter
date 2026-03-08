import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrisphere_flutter/core/error/failures.dart';
import 'package:nutrisphere_flutter/features/fitness/domain/entities/fitness_entity.dart';
import 'package:nutrisphere_flutter/features/fitness/domain/repositories/fitness_repository.dart';
import 'package:nutrisphere_flutter/features/fitness/domain/usecases/delete_fitness_usecase.dart';

class _FakeFitnessRepository implements IFitnessRepository {
  String? deletedId;

  @override
  Future<Either<Failure, bool>> deleteFitness(String fitnessId) async {
    deletedId = fitnessId;
    return const Right(true);
  }

  @override
  Future<Either<Failure, bool>> createFitness(FitnessEntity fitness) => throw UnimplementedError();
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
  @override
  Future<Either<Failure, bool>> updateFitness(FitnessEntity fitness) => throw UnimplementedError();
}

void main() {
  test('DeleteFitnessUsecase sends id to repository', () async {
    final repo = _FakeFitnessRepository();
    final usecase = DeleteFitnessUsecase(fitnessRepository: repo);

    final result = await usecase(const DeleteFitnessParams(fitnessId: 'fit-1'));

    expect(result, const Right(true));
    expect(repo.deletedId, 'fit-1');
  });
}