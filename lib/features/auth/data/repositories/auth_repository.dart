import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutrisphere_flutter/core/error/failures.dart';
import 'package:nutrisphere_flutter/core/services/connectivity/network_info.dart';
import 'package:nutrisphere_flutter/features/auth/data/datasources/auth_datasource.dart';
import 'package:nutrisphere_flutter/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:nutrisphere_flutter/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:nutrisphere_flutter/features/auth/data/models/auth_api_model.dart';
import 'package:nutrisphere_flutter/features/auth/data/models/auth_hive_model.dart';
import 'package:nutrisphere_flutter/features/auth/domain/entities/auth_entity.dart';
import 'package:nutrisphere_flutter/features/auth/domain/repositories/auth_repository.dart';

// provider
final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  final authDatasource = ref.read (authLocalDatasourceProvider);
  final authRemoteDatasource = ref.read (authRemoteDatasourceProvider);
  final networkInfo = ref.read(networkInfoProvider);
  return AuthRepository(
    authDatasource: authDatasource,
    authRemoteDatasource: authRemoteDatasource,
    networkInfo: networkInfo
  );
});

class AuthRepository implements IAuthRepository{
  final IAuthLocalDatasource _authDatasource;
  final IAuthRemoteDatasource _authRemoteDatasource;
  final NetworkInfo _networkInfo;

  AuthRepository({
    required IAuthLocalDatasource authDatasource,
    required IAuthRemoteDatasource authRemoteDatasource,
    required NetworkInfo networkInfo,
  })
      : _authDatasource = authDatasource,
        _authRemoteDatasource = authRemoteDatasource,
        _networkInfo = networkInfo;

  @override
  Future<Either<Failure, bool>> register(AuthEntity user) async {
    if(await _networkInfo.isConnected){
      try{
        // Register from API when internet is available
        final apiModel = AuthApiModel(
          fullName: user.fullName,
          email: user.email,
          password: user.password,
          confirmPassword: user.confirmPassword,
        );
        await _authRemoteDatasource.register(apiModel);
        
        // Also save to Hive for offline reference
        try {
          final hiveModel = AuthHiveModel(
            fullName: user.fullName,
            email: user.email,
            password: user.password,
          );
          await _authDatasource.register(hiveModel);
        } catch (e) {
          print("Note: Could not cache user locally: $e");
        }
        
        return const Right(true);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? e.message ?? "Registration failed",
            statusCode: e.response?.statusCode,
          ),
        );
      }
      catch (e) {
        return Left(ApiFailure(message: "Registration failed: ${e.toString()}"));
      }
    }
    
    // Register offline (Hive)
    try {
      // Check if email already exists
      final existingUser = await _authDatasource.getUserByEmail(user.email);
      if (existingUser != null) {
        return const Left(
          LocaldatabaseFailure(message: "Email already registered"),
        );
      }

      final authModel = AuthHiveModel(
        fullName: user.fullName,
        email: user.email,
        password: user.password,
      );
      await _authDatasource.register(authModel);
      return const Right(true);
    } catch (e) {
      return Left(LocaldatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> login(String email, String password) async {
    if (await _networkInfo.isConnected){
      try{
        // Login from API when internet is available
        final apiModel = await _authRemoteDatasource.login(email, password);
        if (apiModel != null){
          // Also save to Hive for offline use
          try {
            final hiveModel = AuthHiveModel(
              fullName: apiModel.fullName,
              email: apiModel.email,
              password: password, // Store password for offline login
            );
            await _authDatasource.register(hiveModel);
          } catch (e) {
            print("Note: Could not cache user locally: $e");
          }
          
          final entity = apiModel.toEntity();
          return Right(entity);
        }
        return const Left(
          ApiFailure(message: "Invalid Credentials"),
        );
      } on DioException catch (e) {
        return Left(
          ApiFailure(message: e.response?.data['message'] ?? "Login failed",
          statusCode: e.response?.statusCode,
          ),
        );
      }
      catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      // Login from Hive when offline
      try{
        final user = await _authDatasource.login(email, password);
        if (user != null){
          final entity = user.toEntity();
          return Right(entity);
        }
        return const Left(
          LocaldatabaseFailure(message: "Invalid email or password")
        );
      } catch (e) {
        return Left(LocaldatabaseFailure(message: e.toString()));
      }
    }
  }
  
  @override
  Future<Either<Failure, AuthEntity>> getCurrentUser() async {
    try{
      final user = await _authDatasource.getCurrentUser();
      if (user != null){
        final entity = user.toEntity();
        return Right(entity);
      }
      return const Left(
        LocaldatabaseFailure(message: "No user logged in"));
    } catch (e) {
      return Left(LocaldatabaseFailure(message: e.toString()));
    }
    
  }
  
  @override
  Future<Either<Failure, void>> logout() async {
    try{
      final result = await _authDatasource.logout();
      if (result){
        return Right(null);
      }
      return Left(LocaldatabaseFailure(message: "Logout failed"));
    } catch (e) {
      return Left(LocaldatabaseFailure(message: e.toString()));
    }
    
  }
}
