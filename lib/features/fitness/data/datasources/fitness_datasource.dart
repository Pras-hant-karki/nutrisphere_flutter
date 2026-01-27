import 'dart:io';

import 'package:nutrisphere_flutter/features/fitness/data/models/fitness_api_model.dart';
import 'package:nutrisphere_flutter/features/fitness/data/models/fitness_hive_model.dart';

abstract interface class IFitnessLocalDataSource {
  Future<List<FitnessHiveModel>> getAllFitness();
  Future<List<FitnessHiveModel>> getFitnessByCategory(String category);
  Future<FitnessHiveModel?> getFitnessById(String fitnessId);
  Future<bool> createFitness(FitnessHiveModel fitness);
  Future<bool> updateFitness(FitnessHiveModel fitness);
  Future<bool> deleteFitness(String fitnessId);
}

abstract interface class IFitnessRemoteDataSource {
  Future<String> uploadMedia(File media);
  Future<FitnessApiModel> createFitness(FitnessApiModel fitness);
  Future<List<FitnessApiModel>> getAllFitness();
  Future<FitnessApiModel> getFitnessById(String fitnessId);
  Future<List<FitnessApiModel>> getFitnessByCategory(String category);
  Future<bool> updateFitness(FitnessApiModel fitness);
  Future<bool> deleteFitness(String fitnessId);
}
