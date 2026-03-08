import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutrisphere_flutter/core/services/hive/hive_service.dart';
import 'package:nutrisphere_flutter/core/services/storage/user_session_service.dart';
import 'package:nutrisphere_flutter/features/auth/data/datasources/auth_datasource.dart';
import 'package:nutrisphere_flutter/features/auth/data/models/auth_hive_model.dart';

//Provider
final authLocalDatasourceProvider = Provider<AuthLocalDatasource>((ref) {
  final hiveService = ref.read(hiveServiceProvider);
  final userSessionService = ref.read(userSessionServiceProvider);
  return AuthLocalDatasource(
    hiveService: hiveService,
    userSessionService: userSessionService,
    );  // dependency injection
});

class AuthLocalDatasource implements IAuthLocalDatasource {
  final HiveService _hiveService;
  final UserSessionService _userSessionService;

  AuthLocalDatasource({
    required HiveService hiveService,
    required UserSessionService userSessionService,
  })  : _hiveService = hiveService,
        _userSessionService = userSessionService;

  @override
  Future<bool> isEmailExists(String email) {
    try {
      final exists = _hiveService.isEmailExists(email);
      return Future.value(exists);
    } catch (e) {
      return Future.value(false);
    }
  }

  @override
  Future<AuthHiveModel?> login(String email, String password) async{
    try{
      final user = _hiveService.login(email, password);
      // user ko details lai shared prefs ma save garni
      if (user != null) {
        await _userSessionService.saveSession(
          userId: user.authId!,
          email: user.email,
          fullName: user.fullName,
        );
      }
      return user;
    } catch (e) {
      return Future.value(null);
    }
  }

  @override
  Future<AuthHiveModel> register(AuthHiveModel model) async {
    try{
      await _hiveService.registerUser(model);
      return Future.value(model);
    } catch (e) {
      return model;
    }
  }
  
  @override
  Future<AuthHiveModel?> getCurrentUser() async {
    final session = await _userSessionService.getSession();
    if (session == null) return null;

    return _hiveService.getUser(session.email);
  }

    @override
  Future<AuthHiveModel?> getUserByEmail(String email) async {
    return _hiveService.getUser(email);
  }

  @override
  Future<AuthHiveModel?> getUserById(String authId) async {
    // Hive does NOT support ID lookup — email is the key
    return _hiveService.getUser(authId);
  }

  @override
  Future<bool> updateUser(AuthHiveModel user) async {
    return await _hiveService.updateUser(user);
  }

  @override
  Future<bool> deleteUser(AuthHiveModel user) async {
    await _hiveService.deleteUser(user.email);
    return true;
  }

  @override
  Future<bool> logout() async{
    try{
      await _userSessionService.logout();
      return Future.value(true);
    } catch (e) {
      return Future.value(false);
    }
  }
}