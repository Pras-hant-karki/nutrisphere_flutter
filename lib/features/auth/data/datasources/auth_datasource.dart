import 'package:nutrisphere_flutter/features/auth/data/models/auth_api_model.dart';
import 'package:nutrisphere_flutter/features/auth/data/models/auth_hive_model.dart';

/// =======================
/// LOCAL DATASOURCE
/// =======================
abstract interface class IAuthLocalDatasource {
  Future<AuthHiveModel> register(AuthHiveModel user);
  Future<AuthHiveModel?> login(String email, String password);
  Future<AuthHiveModel?> getCurrentUser();
  Future<bool> logout();
  // get email exists
  Future<bool> isEmailExists(String email);
  Future<AuthHiveModel?> getUserByEmail(String email);
  Future<AuthHiveModel?> getUserById(String authId);
  Future<bool> updateUser(AuthHiveModel user);
  Future<bool> deleteUser(AuthHiveModel user);
}

/// =======================
/// REMOTE DATASOURCE
/// =======================
abstract interface class IAuthRemoteDatasource {
  Future<AuthApiModel> register(AuthApiModel model);
  Future<AuthApiModel?> login(String email, String password);
  Future<AuthApiModel?> getCurrentUser();
  Future<bool> logout();
  // get email exists
  Future<bool> isEmailExists(String email);
}
