import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrisphere_flutter/core/error/failures.dart';
import 'package:nutrisphere_flutter/features/fitness/domain/entities/fitness_entity.dart';
import 'package:nutrisphere_flutter/features/fitness/domain/repositories/fitness_repository.dart';
import 'package:nutrisphere_flutter/features/fitness/domain/usecases/create_fitness_usecase.dart';

class _FakeFitnessRepository implements IFitnessRepository {
  _FakeFitnessRepository(this.result);

  final Either<Failure, bool> result;
  FitnessEntity? received;

  @override
  Future<Either<Failure, bool>> createFitness(FitnessEntity fitness) async {
    received = fitness;
    return result;
  }

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

  @override
  Future<Either<Failure, bool>> updateFitness(FitnessEntity fitness) => throw UnimplementedError();
}

void main() {
  group('CreatefitnessUsecase', () {
    test('returns Right(true) and maps title', () async {
      final repo = _FakeFitnessRepository(const Right(true));
      final usecase = CreatefitnessUsecase(fitnessRepository: repo);

      final result = await usecase(const CreateFitnessParams(title: 'Yoga'));

      expect(result, const Right(true));
      expect(repo.received?.title, 'Yoga');
    });

  });
}