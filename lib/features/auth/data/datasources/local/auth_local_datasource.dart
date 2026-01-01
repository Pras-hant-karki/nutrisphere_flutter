import 'package:hive/hive.dart';
import '../../models/auth_hive_model.dart';
import '../auth_datasource.dart';
import '../../../../core/constants/hive_table_constant.dart';

class AuthLocalDataSource implements AuthDataSource {
  final Box<AuthHiveModel> _userBox;

  AuthLocalDataSource(this._userBox);

  @override
  Future<void> registerUser(AuthHiveModel user) async {
    await _userBox.put(user.username, user);
  }

  @override
  Future<AuthHiveModel?> loginUser(
    String username,
    String password,
  ) async {
    final user = _userBox.get(username);

    if (user == null) return null;
    if (user.password != password) return null;

    return user;
  }
}
