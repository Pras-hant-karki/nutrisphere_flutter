import '../models/auth_hive_model.dart';

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

abstract interface class IAuthRemoteDatasource {
  Future<bool> register(AuthApiModel model);
  Future<AuthApiModel?> login(String email, String password);
  Future<AuthApiModel?> getCurrentUser();
  Future<bool> logout();
  // get email exists
  Future<bool> isEmailExists(String email);
}
