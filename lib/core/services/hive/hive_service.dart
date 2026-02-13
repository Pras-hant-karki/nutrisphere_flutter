import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nutrisphere_flutter/core/constants/hive_table_constants.dart';
import 'package:nutrisphere_flutter/features/fitness/data/models/fitness_hive_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:nutrisphere_flutter/features/auth/data/models/auth_hive_model.dart';
import 'package:nutrisphere_flutter/core/models/session_hive_model.dart';

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
  if (!Hive.isAdapterRegistered(HiveTableConstants.fitnessTypeId)) {
    Hive.registerAdapter(FitnessHiveModelAdapter());
  }
  if (!Hive.isAdapterRegistered(HiveTableConstants.sessionTypeId)) {
    Hive.registerAdapter(SessionHiveModelAdapter());
  }
}
  
  /// Open required Hive boxes
  Future<void> _openBoxes() async {
  await Hive.openBox<AuthHiveModel>(HiveTableConstants.authTable);
  await Hive.openBox<FitnessHiveModel>(HiveTableConstants.fitnessTable);
  await Hive.openBox<SessionHiveModel>(HiveTableConstants.sessionTable);
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
  AuthHiveModel? login(String email, String password) {
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

  // ======================= fitness Queries =========================

  Box<FitnessHiveModel> get _fitnessBox =>
      Hive.box<FitnessHiveModel>(HiveTableConstants.fitnessTable);

  Future<FitnessHiveModel> createFitness(FitnessHiveModel fitness) async {
    await _fitnessBox.put(fitness.fitnessId, fitness);
    return fitness;
  }

  List<FitnessHiveModel> getAllFitness() {
    return _fitnessBox.values.toList();
  }

  FitnessHiveModel? getFitnessById(String fitnessId) {
    return _fitnessBox.get(fitnessId);
  }

  List<FitnessHiveModel> getFitnessByUser(String userId) {
    return _fitnessBox.values.where((fitness) => fitness.createdBy == userId).toList();
  }

  List<FitnessHiveModel> getFitnessByCategory(String categoryId) {
    return _fitnessBox.values
        .where((fitness) => fitness.category == categoryId)
        .toList();
  }

  Future<bool> updateFitness(FitnessHiveModel fitness) async {
    if (_fitnessBox.containsKey(fitness.fitnessId)) {
      await _fitnessBox.put(fitness.fitnessId, fitness);
      return true;
    }
    return false;
  }

  Future<void> deleteFitness(String fitnessId) async {
    await _fitnessBox.delete(fitnessId);
  }

  // ======================= session Queries =========================

  Box<SessionHiveModel> get _sessionBox =>
      Hive.box<SessionHiveModel>(HiveTableConstants.sessionTable);

  Future<SessionHiveModel> createSession(SessionHiveModel session) async {
    final key = '${session.day}_${session.sessionName}';
    await _sessionBox.put(key, session);
    return session;
  }

  List<SessionHiveModel> getAllSessions() {
    return _sessionBox.values.toList();
  }

  Future<bool> updateSession(SessionHiveModel session) async {
    final key = '${session.day}_${session.sessionName}';
    if (_sessionBox.containsKey(key)) {
      await _sessionBox.put(key, session);
      return true;
    }
    return false;
  }

  Future<void> deleteSession(String day, String sessionName) async {
    final key = '${day}_${sessionName}';
    await _sessionBox.delete(key);
  }

  Future<void> saveAllSessions(List<SessionHiveModel> sessions) async {
    // Clear old entries first, then save all current sessions
    await _sessionBox.clear();
    final map = <String, SessionHiveModel>{};
    for (int i = 0; i < sessions.length; i++) {
      // Use index in key to avoid collisions between same-day/same-name sessions
      final s = sessions[i];
      map['${i}_${s.day}_${s.sessionName}'] = s;
    }
    await _sessionBox.putAll(map);
    print('[HiveService] Saved ${sessions.length} sessions to Hive');
  }
}
