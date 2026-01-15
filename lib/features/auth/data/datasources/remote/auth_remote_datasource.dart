import 'package:flutter_riverpod/flutter_riverpod.dart';
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

    @override
  Future<AuthApiModel> register(AuthApiModel user) async{
    final response = await _apiClient.post(
      ApiEndpoints.register,
      data: user.toJson(),
    );

    if (response.data['success'] == true){
      final data = response.data['data'] as Map<String, dynamic>;
      final registeredUser = AuthApiModel.fromJson(data);
      return registeredUser;
    }

    return user;
  }
  
  @override
  Future<AuthApiModel?> login(String email, String password) async {
    final resonse = await _apiClient.post(
      ApiEndpoints.login,
      data: {
        'email': email,
        'password': password,
      },
    );

    if (resonse.data['success'] == true){
      final data = resonse.data['data'] as Map<String, dynamic>;
      final loggedInUser = AuthApiModel.fromJson(data);

      // save session
      await _userSessionService.saveUserSession(
        authId: loggedInUser.authId!,
        email: loggedInUser.email,
        fullName: loggedInUser.fullname,
      );

      return loggedInUser;
    }
    return null;
  }
  
  @override
  getCurrentUser() {
    // TODO: implement getCurrentUser
    throw UnimplementedError();
  }
  
  @override
  Future<bool> isEmailExists(String email) {
    // TODO: implement isEmailExists
    throw UnimplementedError();
  }
  
  @override
  Future<bool> logout() {
    // TODO: implement logout
    throw UnimplementedError();
  }
  
}
