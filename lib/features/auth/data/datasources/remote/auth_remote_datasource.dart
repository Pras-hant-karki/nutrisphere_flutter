import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:nutrisphere_flutter/core/api/api_client.dart';
import 'package:nutrisphere_flutter/core/api/api_endpoints.dart';
import 'package:nutrisphere_flutter/core/services/storage/user_session_service.dart';
import 'package:nutrisphere_flutter/features/auth/data/datasources/auth_datasource.dart';
import 'package:nutrisphere_flutter/features/auth/data/models/auth_api_model.dart';

// Provider for AuthRemoteDatasource
final authRemoteDatasourceProvider = Provider<IAuthRemoteDatasource>((ref) {
  return AuthRemoteDatasource(apiClient: ref.read(apiClientProvider), 
  userSessionService: ref.read(userSessionServiceProvider)
  );
});


class AuthRemoteDatasource implements IAuthRemoteDatasource {

  final ApiClient _apiClient;
  final UserSessionService _userSessionService;

  AuthRemoteDatasource({
    required ApiClient apiClient,
    required UserSessionService userSessionService,
  }) : _apiClient = apiClient,
    _userSessionService = userSessionService;

///Register
    @override
  Future<AuthApiModel> register(AuthApiModel user) async{
    try {
      final response = await _apiClient.post(
        ApiEndpoints.register,
        data: user.toJson(),
      );

      // Check if registration was successful
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Handle different response formats
        if (response.data != null && response.data is Map) {
          final Map<String, dynamic> responseData = response.data as Map<String, dynamic>;
          
          // Extract token if provided
          final String? token = responseData['token'] as String?;
          if (token != null) {
            // Save token to secure storage
            const _storage = FlutterSecureStorage();
            await _storage.write(key: 'auth_token', value: token);
          }
          
          // Get user data - could be in 'user' field or 'data' field
          final Map<String, dynamic> userData;
          if (responseData['user'] is Map) {
            userData = responseData['user'] as Map<String, dynamic>;
          } else if (responseData['data'] is Map) {
            userData = responseData['data'] as Map<String, dynamic>;
          } else {
            userData = responseData;
          }
          
          final registeredUser = AuthApiModel.fromJson(userData);
          
          // Save session (IMPORTANT: This was missing!)
          if (registeredUser.authId != null && registeredUser.email != null) {
            await _userSessionService.saveUserSession(
              authId: registeredUser.authId!,
              email: registeredUser.email!,
              fullName: registeredUser.fullName ?? 'User',
            );
          }
          
          return registeredUser;
        }
      }
      
      throw Exception('Registration failed: Invalid response format');
    } catch (e) {
      rethrow;
    }
  }
  
/// Login
  @override
  Future<AuthApiModel?> login(String email, String password) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data != null && response.data is Map) {
          final Map<String, dynamic> responseData = response.data as Map<String, dynamic>;
          
          // Extract token if provided
          final String? token = responseData['token'] as String?;
          if (token != null) {
            // Save token to secure storage
            const _storage = FlutterSecureStorage();
            await _storage.write(key: 'auth_token', value: token);
          }
          
          // Handle different response formats from backend
          final Map<String, dynamic> userData;
          if (responseData['user'] is Map) {
            userData = responseData['user'] as Map<String, dynamic>;
          } else if (responseData['data'] is Map) {
            userData = responseData['data'] as Map<String, dynamic>;
          } else {
            userData = responseData;
          }
          
          final loggedInUser = AuthApiModel.fromJson(userData);

          // save session
          if (loggedInUser.authId != null && loggedInUser.email != null) {
            await _userSessionService.saveUserSession(
              authId: loggedInUser.authId!,
              email: loggedInUser.email!,
              fullName: loggedInUser.fullName ?? 'User',
            );
          }

          return loggedInUser;
        }
      }
      return null;
    } catch (e) {
      print('Login Error: $e');
      rethrow;
    }
  }
  
  @override
  Future<AuthApiModel?> getCurrentUser() async {
    final session = await _userSessionService.getSession();
    if (session == null) return null;

    try {
      final response = await _apiClient.get(ApiEndpoints.me);

      if (response.data['success'] != true) return null;

      final data = response.data['data'] as Map<String, dynamic>;
      return AuthApiModel.fromJson(data);
    } catch (_) {
      return null;
    }
  }
  
  @override
  Future<bool> isEmailExists(String email) async {
    return false;
  }

  // LOGOUT
  @override
  Future<bool> logout() async {
    await _userSessionService.logout();
    return true;
  }
  
}
