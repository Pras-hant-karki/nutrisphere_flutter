import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutrisphere_flutter/core/services/hive/hive_service.dart';
import 'package:nutrisphere_flutter/features/fitness/data/datasources/fitness_datasource.dart';
import 'package:nutrisphere_flutter/features/fitness/data/models/fitness_hive_model.dart';

final fitnessLocalDatasourceProvider = Provider<IFitnessLocalDataSource>((ref) {
  final hiveService = ref.read(hiveServiceProvider);
  return FitnessLocalDatasource(hiveService: hiveService);
});

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
  Future<bool> deleteFitness(String fitnessId) async {
    try {
      await _hiveService.deleteFitness(fitnessId);
      return true;
    } catch (e) {
      return false;
    }
  }
  
  @override
  Future<List<FitnessHiveModel>> getAllFitness() async {
    try {
      return _hiveService.getAllFitness();  
    } catch (e) {
      return [];
    }
  }
  
  @override
  Future<List<FitnessHiveModel>> getFitnessByCategory(String category) async {
    try {
      return _hiveService.getFitnessByCategory(category);
    } catch (e) {
      return [];
    }
  }
  
  @override
  Future<FitnessHiveModel?> getFitnessById(String fitnessId) async {
    try {
      return _hiveService.getFitnessById(fitnessId);
    } catch (e) {
      return null;
    }
  }
  
  @override
  Future<bool> updateFitness(FitnessHiveModel fitness) async {
    try {
      await _hiveService.updateFitness(fitness);
      return true;
    } catch (e) {
      return false;
    }
  }
}