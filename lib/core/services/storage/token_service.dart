import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenService {
  static const _tokenKey = 'auth_token';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<void> clearToken() async {
    await _storage.delete(key: _tokenKey);
  }
}



// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:nutrisphere_flutter/core/services/storage/user_session_service.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// // provider
// final tokenServiceProvider = Provider<TokenService>((ref) {
//   return TokenService(prefs: ref.read(sharedPreferencesProvider));
// });

// class TokenService {
//   static const String _tokenKey = 'auth_token';
//   final SharedPreferences _prefs;

//   TokenService({required SharedPreferences prefs}) : _prefs = prefs;

//   // Save token
//   Future<void> saveToken(String token) async {
//     await _prefs.setString(_tokenKey, token);
//   }

//   // Get token
//   Future<String?> getToken() async {
//     return _prefs.getString(_tokenKey);
//   }

//   // Remove token (for logout)
//   Future<void> removeToken() async {
//     await _prefs.remove(_tokenKey);
//   }
// }

