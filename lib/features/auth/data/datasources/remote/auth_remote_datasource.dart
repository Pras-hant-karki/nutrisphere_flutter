import 'dart:io';

import 'package:dio/dio.dart';
// import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutrisphere_flutter/core/api/api_client.dart';
import 'package:nutrisphere_flutter/core/api/api_endpoints.dart';
import 'package:nutrisphere_flutter/core/services/storage/token_service.dart';
import 'package:nutrisphere_flutter/core/services/storage/user_session_service.dart';
import 'package:nutrisphere_flutter/features/auth/data/datasources/auth_datasource.dart';
import 'package:nutrisphere_flutter/features/auth/data/models/auth_api_model.dart';

// Provider for AuthRemoteDatasource
final authRemoteDatasourceProvider = Provider<IAuthRemoteDatasource>((ref) {
  return AuthRemoteDatasource(
    apiClient: ref.read(apiClientProvider),
    userSessionService: ref.read(userSessionServiceProvider),
    tokenService: ref.read(tokenServiceProvider),
  );
});

/// Abstract interface for remote authentication data source
abstract class AuthRemoteDataSource {
  Future<AuthApiModel> register({
    required String email,
    required String password,
    required String name,
  });

  Future<AuthApiModel> login(String email, String password);
  Future<AuthApiModel> getUserById(String authId);
  Future<AuthApiModel> updateUser(AuthApiModel user);
  Future<AuthApiModel> uploadProfilePicture(File image);
}

class AuthRemoteDatasource implements IAuthRemoteDatasource {
  final ApiClient _apiClient;
  final UserSessionService _userSessionService;
  final TokenService _tokenService;
  

  AuthRemoteDatasource({
    required ApiClient apiClient,
    required UserSessionService userSessionService,
    required TokenService tokenService,
  })  : _apiClient = apiClient,
        _userSessionService = userSessionService,
        _tokenService = tokenService;

  @override
  Future<AuthApiModel> login(String email, String password) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.login,
        data: {'email': email, 'password': password},
      );

      // safety checks (prevents crash)
      if (response.data == null || response.data is! Map<String, dynamic>) {
        throw Exception("Invalid login response: ${response.data}");
      }

      final resData = response.data as Map<String, dynamic>;

      if (response.statusCode == 200 && resData['success'] == true) {
        // backend returns user inside "user"
        final userData = resData['user'];

        if (userData == null || userData is! Map<String, dynamic>) {
          throw Exception("Login failed: user data missing");
        }

        final loggedInUser = AuthApiModel.fromJson(userData);

        // token is at root level
        final token = resData['token'];
        if (token != null && token is String && token.isNotEmpty) {
          _apiClient.setAuthToken(token);
          await _tokenService.saveToken(token);
        } else {
          throw Exception("Login failed: token missing");
        }

        // Save user session with full data from backend
        await _userSessionService.saveSession(
          userId: loggedInUser.authId ?? userData['_id']?.toString() ?? '',
          email: loggedInUser.email,
          fullName: loggedInUser.fullName,
          role: loggedInUser.role,
          phone: loggedInUser.phone,
          profilePicture: loggedInUser.profilePicture,
        );

        return loggedInUser;
      }

      throw Exception(resData['message'] ?? 'Login failed');
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  // @override
  // Future<AuthApiModel> login(String email, String password) async {
  //   try {
  //     final response = await _apiClient.post(
  //       ApiEndpoints.login,
  //       data: {'email': email, 'password': password},
  //     );

  //     if (response.statusCode == 200) {
  //       if (response.data['success'] == true) {
  //         final data = response.data['data'] as Map<String, dynamic>;
  //         final loggedInUser = AuthApiModel.fromJson(data);

  //         // Set auth token if available - token is at root level in response
  //         if (response.data['token'] != null) {
  //           _apiClient.setAuthToken(response.data['token']);

  //           // Save token to storage for later use
  //           final token = response.data['token'] as String;
  //           await _tokenService.saveToken(token);
  //         }

  //         return loggedInUser;
  //       }
  //     }
  //     throw Exception(response.data['message'] ?? 'Login failed');
  //   } catch (e) {
  //     throw Exception('Login failed: ${e.toString()}');
  //   }
  // }

  @override
Future<AuthApiModel> register({
  required String email,
  required String password,
  required String name,
  required String confirmPassword,
}) async {
  try {
    final authModel = AuthApiModel(
      fullName: name,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
    );

    final response = await _apiClient.post(
      ApiEndpoints.register,
      data: authModel.toJson(),
    );

    // safety checks
    if (response.data == null || response.data is! Map<String, dynamic>) {
      throw Exception("Invalid register response: ${response.data}");
    }

    final resData = response.data as Map<String, dynamic>;

    if ((response.statusCode == 201 || response.statusCode == 200) &&
        resData['success'] == true) {
      // backend returns user inside "user"
      final userData = resData['user'];

      if (userData == null || userData is! Map<String, dynamic>) {
        throw Exception("Registration failed: user data missing");
      }

      final registeredUser = AuthApiModel.fromJson(userData);

      // token is at root level
      final token = resData['token'];
      if (token != null && token is String && token.isNotEmpty) {
        _apiClient.setAuthToken(token);
        await _tokenService.saveToken(token);
      }

      return registeredUser;
    }

    throw Exception(resData['message'] ?? 'Registration failed');
  } catch (e) {
    throw Exception('Registration failed: ${e.toString()}');
  }
}


  // @override
  // Future<AuthApiModel> register({
  //   required String email,
  //   required String password,
  //   required String name,
  // }) async {
  //   try {
  //     final authModel = AuthApiModel(
  //       fullName: name,
  //       email: email,
  //       password: password,
  //     );

  //     final response = await _apiClient.post(
  //       ApiEndpoints.register,
  //       data: authModel.toJson(),
  //     );

  //     if (response.statusCode == 201 || response.statusCode == 200) {
  //       if (response.data['success'] == true) {
  //         final data = response.data['data'] as Map<String, dynamic>;
  //         final registeredUser = AuthApiModel.fromJson(data);

  //         // Set auth token if available - token is at root level in response
  //         if (response.data['token'] != null) {
  //           _apiClient.setAuthToken(response.data['token']);

  //           // Save token to storage for later use
  //           final prefs = await SharedPreferences.getInstance();
  //           final tokenService = TokenService(prefs);
  //           await tokenService.saveToken(response.data['token']);
  //         }

  //         return registeredUser;
  //       }
  //     }
  //     throw Exception(response.data['message'] ?? 'Registration failed');
  //   } catch (e) {
  //     throw Exception('Registration failed: ${e.toString()}');
  //   }
  // }

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

  // LOGOUT
  @override
  Future<bool> logout() async {
    await _tokenService.removeToken();

    // remove token from Dio header 
    _apiClient.removeAuthToken();

    await _userSessionService.logout();
    return true;
  }

  @override
  Future<String> uploadProfilePicture(File image) async {
    try {
      final fileName = image.path.split('/').last;

      final formData = FormData.fromMap({
        "fitnessPhoto": await MultipartFile.fromFile(
          image.path,
          filename: fileName,
        ),
      });

      final response = await _apiClient.uploadFile(
        ApiEndpoints.uploadImage, // should be "/api/fitness/upload-photo"
        formData: formData,
      );

      if (response.statusCode == 200) {
        return response.data["data"].toString();
      }

      throw Exception("Upload failed: ${response.data}");
    } catch (e) {
      throw Exception("Failed to upload image: $e");
    }
  }


  // @override
  // Future<AuthApiModel> uploadProfilePicture(File image) async {
  //   try {
  //     String fileName = image.path.split('/').last;
  //     AuthApiModel formData = AuthApiModel.fromJson({
  //       "profileImage": await MultipartFile.fromFile(
  //         image.path,
  //         filename: fileName,
  //       ),
  //     });

  //     final response = await _apiClient.post(
  //       ApiEndpoints.uploadImage, // Ensure this exists in your ApiEndpoints
  //       data: formData,
  //     );

  //     if (response.statusCode == 200) {
  //       // Return the image name returned by backend (e.g., "123-profile.jpg")
  //       return response.data['data'];
  //     }
  //     throw Exception('Upload failed');
  //   } catch (e) {
  //     throw Exception('Failed to upload image: ${e.toString()}');
  //   }
  // }

  @override
  Future<bool> isEmailExists(String email) {
    // TODO: implement isEmailExists
    throw UnimplementedError();
  }
}
