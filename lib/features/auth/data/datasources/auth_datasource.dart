import '../models/auth_hive_model.dart';

abstract class AuthDataSource {
  Future<void> registerUser(AuthHiveModel user);
  Future<AuthHiveModel?> loginUser(String username, String password);
}
