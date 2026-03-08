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

/// Simple session model
class UserSession {
  final String userId;
  final String email;
  final String fullName;

  UserSession({
    required this.userId,
    required this.email,
    required this.fullName,
  });
}

class UserSessionService {
  final SharedPreferences _prefs;

  static const _keyIsLoggedIn = 'is_logged_in';
  static const _keyUserId = 'user_id';
  static const _keyEmail = 'email';
  static const _keyFullName = 'full_name';

  UserSessionService({required SharedPreferences prefs}) : _prefs = prefs;

  /// Save session (LOCAL + REMOTE use the same method)
  Future<void> saveSession({
    required String userId,
    required String email,
    required String fullName,
  }) async {
    await _prefs.setBool(_keyIsLoggedIn, true);
    await _prefs.setString(_keyUserId, userId);
    await _prefs.setString(_keyEmail, email);
    await _prefs.setString(_keyFullName, fullName);
  }

  /// Alias for remote datasource (so nothing breaks)
  Future<void> saveUserSession({
    required String authId,
    required String email,
    required String fullName,
  }) async {
    await saveSession(
      userId: authId,
      email: email,
      fullName: fullName,
    );
  }

  /// Get current session
  Future<UserSession?> getSession() async {
    final isLoggedIn = _prefs.getBool(_keyIsLoggedIn) ?? false;
    if (!isLoggedIn) return null;

    final userId = _prefs.getString(_keyUserId);
    final email = _prefs.getString(_keyEmail);
    final fullName = _prefs.getString(_keyFullName);

    if (userId == null || email == null || fullName == null) {
      return null;
    }

    return UserSession(
      userId: userId,
      email: email,
      fullName: fullName,
    );
  }

  /// Logout
  Future<void> logout() async {
    await _prefs.remove(_keyIsLoggedIn);
    await _prefs.remove(_keyUserId);
    await _prefs.remove(_keyEmail);
    await _prefs.remove(_keyFullName);
  }

  /// Quick checks
  bool isLoggedIn() => _prefs.getBool(_keyIsLoggedIn) ?? false;
}
