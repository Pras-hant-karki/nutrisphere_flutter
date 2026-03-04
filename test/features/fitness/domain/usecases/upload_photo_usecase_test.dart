import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrisphere_flutter/core/error/failures.dart';
import 'package:nutrisphere_flutter/features/fitness/domain/entities/fitness_entity.dart';
import 'package:nutrisphere_flutter/features/fitness/domain/repositories/fitness_repository.dart';
import 'package:nutrisphere_flutter/features/fitness/domain/usecases/upload_photo_usecase.dart';

class _FakeFitnessRepository implements IFitnessRepository {
  @override
  Future<Either<Failure, String>> uploadPhoto(File photo) async => const Right('/uploads/photo.png');

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
  Future<Either<Failure, String>> uploadVideo(File video) => throw UnimplementedError();
  @override
  Future<Either<Failure, bool>> updateFitness(FitnessEntity fitness) => throw UnimplementedError();
}

void main() {
  test('UploadPhotoUsecase returns uploaded path', () async {
    final usecase = UploadPhotoUsecase(fitnessRepository: _FakeFitnessRepository());

    final result = await usecase(File('photo.png'));

    expect(result, const Right('/uploads/photo.png'));
  });
}