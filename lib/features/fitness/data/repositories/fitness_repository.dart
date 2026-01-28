import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutrisphere_flutter/core/error/failures.dart';
import 'package:nutrisphere_flutter/core/services/connectivity/network_info.dart';
import 'package:nutrisphere_flutter/features/fitness/data/datasources/fitness_datasource.dart';
import 'package:nutrisphere_flutter/features/fitness/data/datasources/local/fitness_local_datasource.dart';
import 'package:nutrisphere_flutter/features/fitness/data/datasources/remote/fitness_remote_datasource.dart';
import 'package:nutrisphere_flutter/features/fitness/data/models/fitness_api_model.dart';
import 'package:nutrisphere_flutter/features/fitness/data/models/fitness_hive_model.dart';
import 'package:nutrisphere_flutter/features/fitness/domain/entities/fitness_entity.dart';
import 'package:nutrisphere_flutter/features/fitness/domain/repositories/fitness_repository.dart';

final fitnessRepositoryProvider = Provider<IFitnessRepository>((ref) {
  final localDatasource = ref.read(fitnessLocalDatasourceProvider);
  final remoteDatasource = ref.read(fitnessRemoteDatasourceProvider);
  final networkInfo = ref.read(networkInfoProvider);
  return FitnessRepository(
    localDatasource: localDatasource,
    remoteDatasource: remoteDatasource,
    networkInfo: networkInfo,
  );
});

class FitnessRepository implements IFitnessRepository {
  final IFitnessLocalDataSource _localDataSource;
  final IFitnessRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  FitnessRepository({
    required IFitnessLocalDataSource localDatasource,
    required IFitnessRemoteDataSource remoteDatasource,
    required NetworkInfo networkInfo,
  }) : _localDataSource = localDatasource,
       _remoteDataSource = remoteDatasource,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failure, bool>> createFitness(FitnessEntity fitness) async {
    if (await _networkInfo.isConnected) {
      try {
        final fitnessApiModel = FitnessApiModel.fromEntity(fitness);
        await _remoteDataSource.createFitness(fitnessApiModel);
        return const Right(true);
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteFitness(String fitnessId) async {
    if (await _networkInfo.isConnected) {
      try {
        await _remoteDataSource.deleteFitness(fitnessId);
        return const Right(true);
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final result = await _localDataSource.deleteFitness(fitnessId);
        if (result) {
          return const Right(true);
        }
        return const Left(
          LocaldatabaseFailure(message: "Failed to delete fitness"),
        );
      } catch (e) {
        return Left(LocaldatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, List<FitnessEntity>>> getAllFitness() async {
    if (await _networkInfo.isConnected) {
      try {
        final models = await _remoteDataSource.getAllFitness();
        final entities = FitnessApiModel.toEntityList(models);
        return Right(entities);
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final models = await _localDataSource.getAllFitness();
        final entities = FitnessHiveModel.toEntityList(models);
        return Right(entities);
      } catch (e) {
        return Left(LocaldatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, FitnessEntity>> getFitnessById(String fitnessId) async {
    if (await _networkInfo.isConnected) {
      try {
        final model = await _remoteDataSource.getFitnessById(fitnessId);
        return Right(model.toEntity());
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final model = await _localDataSource.getFitnessById(fitnessId);
        if (model != null) {
          return Right(model.toEntity());
        }
        return const Left(LocaldatabaseFailure(message: 'Fitness not found'));
      } catch (e) {
        return Left(LocaldatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, List<FitnessEntity>>> getFitnessByCategory(
    String category,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final models = await _remoteDataSource.getFitnessByCategory(category);
        final entities = FitnessApiModel.toEntityList(models);
        return Right(entities);
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final models = await _localDataSource.getFitnessByCategory(category);
        final entities = FitnessHiveModel.toEntityList(models);
        return Right(entities);
      } catch (e) {
        return Left(LocaldatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, bool>> updateFitness(FitnessEntity fitness) async {
    if (await _networkInfo.isConnected) {
      try {
        final fitnessApiModel = FitnessApiModel.fromEntity(fitness);
        await _remoteDataSource.updateFitness(fitnessApiModel);
        return const Right(true);
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final fitnessModel = FitnessHiveModel.fromEntity(fitness);
        final result = await _localDataSource.updateFitness(fitnessModel);
        if (result) {
          return const Right(true);
        }
        return const Left(
          LocaldatabaseFailure(message: "Failed to update fitness"),
        );
      } catch (e) {
        return Left(LocaldatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, String>> uploadPhoto(File photo) async {
    if (await _networkInfo.isConnected) {
      try {
        final url = await _remoteDataSource.uploadPhoto(photo);
        return Right(url);
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }
  
  @override
  Future<Either<Failure, String>> uploadVideo(File video) async {
    if (await _networkInfo.isConnected) {
      try {
        final url = await _remoteDataSource.uploadVideo(video);
        return Right(url);
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }
}