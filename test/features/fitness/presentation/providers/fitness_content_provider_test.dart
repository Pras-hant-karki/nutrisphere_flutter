import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrisphere_flutter/core/error/failures.dart';
import 'package:nutrisphere_flutter/features/fitness/domain/entities/fitness_entity.dart';
import 'package:nutrisphere_flutter/features/fitness/domain/repositories/fitness_repository.dart';
import 'package:nutrisphere_flutter/features/fitness/domain/usecases/get_all_fitness_usecase.dart';
import 'package:nutrisphere_flutter/features/fitness/presentation/providers/fitness_content_provider.dart';

class _FakeFitnessRepository implements IFitnessRepository {
  _FakeFitnessRepository(this.result);
  final Either<Failure, List<FitnessEntity>> result;

  @override
  Future<Either<Failure, List<FitnessEntity>>> getAllFitness() async => result;

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
  group('FitnessContentNotifier', () {
    test('loads data successfully', () async {
      final repo = _FakeFitnessRepository(const Right([FitnessEntity(fitnessId: '1', title: 'Yoga')]));
      final notifier = FitnessContentNotifier(getAllFitnessUsecase: GetAllFitnessUsecase(fitnessRepository: repo));

      await notifier.loadFitnessContent();

      expect(notifier.state.hasValue, isTrue);
    });

    test('sets error on failure', () async {
      const failure = ApiFailure(message: 'failed');
      final repo = _FakeFitnessRepository(const Left(failure));
      final notifier = FitnessContentNotifier(getAllFitnessUsecase: GetAllFitnessUsecase(fitnessRepository: repo));

      await notifier.loadFitnessContent();

      expect(notifier.state.hasError, isTrue);
    });

  });
}