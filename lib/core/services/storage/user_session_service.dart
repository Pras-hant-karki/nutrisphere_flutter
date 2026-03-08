import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nutrisphere_flutter/features/auth/domain/entities/auth_entity.dart';

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
  final String? role;
  final String? phone;
  final String? profilePicture;

  UserSession({
    required this.userId,
    required this.email,
    required this.fullName,
    this.role,
    this.phone,
    this.profilePicture,
  });

  UserSession copyWith({
    String? userId,
    String? email,
    String? fullName,
    String? role,
    String? phone,
    String? profilePicture,
  }) {
    return UserSession(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      profilePicture: profilePicture ?? this.profilePicture,
    );
  }

  AuthEntity toEntity() {
    return AuthEntity(
      authId: userId,
      fullName: fullName,
      email: email,
      password: '', // Password not stored in session service
      phone: phone,
      profilePicture: profilePicture,
    );
  }
}

class UserSessionService {
  final SharedPreferences _prefs;

  static const _keyIsLoggedIn = 'is_logged_in';
  static const _keyUserId = 'user_id';
  static const _keyEmail = 'email';
  static const _keyFullName = 'full_name';
  static const _keyRole = 'role';
  static const _keyPhone = 'phone';
  static const _keyProfilePicture = 'profile_picture';

  UserSessionService({required SharedPreferences prefs}) : _prefs = prefs;

  /// Save session (LOCAL + REMOTE use the same method)
  Future<void> saveSession({
    required String userId,
    required String email,
    required String fullName,
    String? role,
    String? phone,
    String? profilePicture,
  }) async {
    await _prefs.setBool(_keyIsLoggedIn, true);
    await _prefs.setString(_keyUserId, userId);
    await _prefs.setString(_keyEmail, email);
    await _prefs.setString(_keyFullName, fullName);
    if (role != null) await _prefs.setString(_keyRole, role);
    if (phone != null) await _prefs.setString(_keyPhone, phone);
    if (profilePicture != null) await _prefs.setString(_keyProfilePicture, profilePicture);
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
      role: _prefs.getString(_keyRole),
      phone: _prefs.getString(_keyPhone),
      profilePicture: _prefs.getString(_keyProfilePicture),
    );
  }

  /// Logout
  Future<void> logout() async {
    await _prefs.remove(_keyIsLoggedIn);
    await _prefs.remove(_keyUserId);
    await _prefs.remove(_keyEmail);
    await _prefs.remove(_keyFullName);
    await _prefs.remove(_keyRole);
    await _prefs.remove(_keyPhone);
    await _prefs.remove(_keyProfilePicture);
  }

  /// Quick checks
  bool isLoggedIn() => _prefs.getBool(_keyIsLoggedIn) ?? false;
}
