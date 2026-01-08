import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// SharedPreferences provider (override in main.dart)
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden in main.dart');
});

// UserSessionService provider
final userSessionServiceProvider = Provider<UserSessionService>((ref) {
  final prefs = ref.read(sharedPreferencesProvider);
  return UserSessionService(prefs: prefs);
});

class UserSessionService {
  final SharedPreferences _prefs;

  static const _keyIsLoggedIn = 'is_logged_in';
  static const _keyUserId = 'user_id';
  static const _keyEmail = 'email';
  static const _keyUsername = 'username';
  static const _keyFullName = 'full_name';

  UserSessionService({required SharedPreferences prefs}) : _prefs = prefs;

  /// Save session after login
  Future<void> saveSession({
    required String userId,
    required String email,
    required String username,
    required String fullName,
  }) async {
    await _prefs.setBool(_keyIsLoggedIn, true);
    await _prefs.setString(_keyUserId, userId);
    await _prefs.setString(_keyEmail, email);
    await _prefs.setString(_keyUsername, username);
    await _prefs.setString(_keyFullName, fullName);
  }

  // clear user session data
  Future<void> clearUserSession() async {
    await _prefs.remove(_keyIsLoggedIn);
    await _prefs.remove(_keyUserId);
    await _prefs.remove(_keyEmail);
    await _prefs.remove(_keyUsername);
    await _prefs.remove(_keyFullName);
  }

  bool isLoggedIn() => _prefs.getBool(_keyIsLoggedIn) ?? false;

  String? get userId => _prefs.getString(_keyUserId);
  String? get email => _prefs.getString(_keyEmail);
  String? get username => _prefs.getString(_keyUsername);
  String? get fullName => _prefs.getString(_keyFullName);

  /// Logout
  Future<void> clearSession() async {
    await _prefs.clear();
  }
}
