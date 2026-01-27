import 'package:nutrisphere_flutter/core/services/hive/hive_service.dart';
import 'package:nutrisphere_flutter/features/fitness/data/datasources/fitness_datasource.dart';
import 'package:nutrisphere_flutter/features/fitness/data/models/fitness_hive_model.dart';

class FitnessLocalDatasource implements IFitnessLocalDataSource {
  final HiveService _hiveService;

  FitnessLocalDatasource({required HiveService hiveService})
      : _hiveService = hiveService;

  @override
  Future<bool> createFitness(FitnessHiveModel fitness) async {
    try {
      await _hiveService.createFitness(fitness);
      return true;
    } catch (e) {
      return false;
    }
  }
  
  @override
  Future<bool> deleteFitness(String fitnessId) {
    // TODO: implement deleteFitness
    throw UnimplementedError();
  }
  
  @override
  Future<List<FitnessHiveModel>> getAllFitness() {
    // TODO: implement getAllFitness
    throw UnimplementedError();
  }
  
  @override
  Future<List<FitnessHiveModel>> getFitnessByCategory(String category) {
    // TODO: implement getFitnessByCategory
    throw UnimplementedError();
  }
  
  @override
  Future<FitnessHiveModel?> getFitnessById(String fitnessId) {
    // TODO: implement getFitnessById
    throw UnimplementedError();
  }
  
  @override
  Future<bool> updateFitness(FitnessHiveModel fitness) {
    // TODO: implement updateFitness
    throw UnimplementedError();
  }
}