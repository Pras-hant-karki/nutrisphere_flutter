import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nutrisphere_flutter/core/constants/hive_table_constants.dart';
import 'package:path_provider/path_provider.dart';
import 'package:nutrisphere_flutter/features/auth/data/models/auth_hive_model.dart';

final hiveServiceProvider = Provider<HiveService>((ref) {
  return HiveService();
});

class HiveService {
  /// Initialize Hive
  Future<void> init() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/${HiveTableConstants.dbName}';

    Hive.init(path);

    _registerAdapters();
    await _openBoxes();
  }

  /// Register Hive adapters
  void _registerAdapters() {
    if (!Hive.isAdapterRegistered(HiveTableConstants.authTypeId)) {
      Hive.registerAdapter(AuthHiveModelAdapter());
    }
  }

  /// Open required Hive boxes
  Future<void> _openBoxes() async {
    await Hive.openBox<AuthHiveModel>(HiveTableConstants.authTable);
  }

  /// Close Hive
  Future<void> close() async {
    await Hive.close();
  }

  // ======================= AUTH QUERIES =======================

  Box<AuthHiveModel> get _authBox =>
      Hive.box<AuthHiveModel>(HiveTableConstants.authTable);

  /// Register user
  Future<AuthHiveModel> registerUser(AuthHiveModel user) async {
    await _authBox.put(user.email, user);
    return user;
  }

  /// Login user
  AuthHiveModel? loginUser(String email, String password) {
    final user = _authBox.get(email);

    if (user == null) return null;
    if (user.password != password) return null;

    return user;
  }

  // Logout (local)
  Future<void> logoutUser() async {
    // await _authBox.delete(authId);
    return;
  }

  /// Get user by email
  AuthHiveModel? getUser(String email) {
    return _authBox.get(email);
  }

  /// Update user
  Future<bool> updateUser(AuthHiveModel user) async {
    if (_authBox.containsKey(user.email)) {
      await _authBox.put(user.email, user);
      return true;
    }
    return false;
  }

  /// Delete user
  Future<void> deleteUser(String email) async {
    await _authBox.delete(email);
  }

  /// Check if email exists
  bool isEmailExists(String email) {
    final users = _authBox.values.where((user) => user.email == email);
    return users.isNotEmpty;
  }
}
