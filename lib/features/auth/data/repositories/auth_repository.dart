import '../datasources/auth_datasource.dart';
import '../models/auth_hive_model.dart';

class AuthRepository {
  final AuthDataSource _dataSource;

  AuthRepository(this._dataSource);

  Future<void> register(AuthHiveModel user) {
    return _dataSource.registerUser(user);
  }

  Future<AuthHiveModel?> login(
    String username,
    String password,
  ) {
    return _dataSource.loginUser(username, password);
  }
}
