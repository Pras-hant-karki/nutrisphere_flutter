import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutrisphere_flutter/core/api/api_client.dart';
import 'package:nutrisphere_flutter/features/auth/data/datasources/auth_datasource.dart';

// Provider for AuthRemoteDatasource
final authRemoteDatasourceProvider = Provider<IAuthRemoteDatasource>((ref) {
  return AuthRemoteDatasource(apiClient: ref.read(apiClientProvider));
});


class AuthRemoteDatasource implements IAuthRemoteDatasource {

  final ApiClient _apiClient;

  AuthRemoteDatasource({required ApiClient apiClient}) 
  : _apiClient = apiClient;

  @override
  getCurrentUser() {
    
    throw UnimplementedError();
  }

  @override
  Future<bool> isEmailExists(String email) {
    // TODO: implement isEmailExists
    throw UnimplementedError();
  }

  @override
  login(String email, String password) {
    // TODO: implement login
    throw UnimplementedError();
  }

  @override
  Future<bool> logout() {
    // TODO: implement logout
    throw UnimplementedError();
  }

  @override
  Future<bool> register(model) {
    // TODO: implement register
    throw UnimplementedError();
  }
  // implementation details
}