import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:nutrisphere_flutter/core/error/failures.dart';
import 'package:nutrisphere_flutter/features/fitness/domain/entities/fitness_entity.dart';

abstract interface class IFitnessRepository {
  Future<Either<Failure, List<FitnessEntity>>> getAllFitness();
  Future<Either<Failure, List<FitnessEntity>>> getFitnessByCategory(
    String categoryId,
  );
  Future<Either<Failure, FitnessEntity>> getFitnessById(String fitnessId);
  Future<Either<Failure, bool>> createFitness(FitnessEntity fitness);
  Future<Either<Failure, bool>> updateFitness(FitnessEntity fitness);
  Future<Either<Failure, bool>> deleteFitness(String fitnessId);
  Future<Either<Failure, String>> uploadPhoto(File photo);
  Future<Either<Failure, String>> uploadVideo(File video);
}


