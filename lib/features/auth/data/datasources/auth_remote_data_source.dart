// import 'package:dio/dio.dart';
// import 'package:nutrisphere_flutter/core/api/api_client.dart';
// import 'package:nutrisphere_flutter/core/api/api_endpoints.dart';
// import 'package:nutrisphere_flutter/features/auth/data/models/auth_response_model.dart';
// import 'package:nutrisphere_flutter/features/auth/data/models/login_request_model.dart';

// abstract interface class IAuthRemoteDataSource {
//   Future<AuthResponseModel> login(LoginRequestModel loginRequest);
//   Future<AuthResponseModel> register(Map<String, dynamic> registerData);
//   Future<AuthResponseModel> getCurrentUser();
// }

// class AuthRemoteDataSource implements IAuthRemoteDataSource {
//   final ApiClient _apiClient;

//   AuthRemoteDataSource(this._apiClient);

//   @override
//   Future<AuthResponseModel> login(LoginRequestModel loginRequest) async {
//     try {
//       final response = await _apiClient.post(
//         ApiEndpoints.login,
//         data: loginRequest.toJson(),
//       );

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         return AuthResponseModel.fromJson(response.data);
//       } else {
//         throw Exception('Failed to login: ${response.statusMessage}');
//       }
//     } on DioException catch (e) {
//       throw Exception('Login error: ${e.message}');
//     }
//   }

//   @override
//   Future<AuthResponseModel> register(Map<String, dynamic> registerData) async {
//     try {
//       final response = await _apiClient.post(
//         ApiEndpoints.register,
//         data: registerData,
//       );

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         return AuthResponseModel.fromJson(response.data);
//       } else {
//         throw Exception('Failed to register: ${response.statusMessage}');
//       }
//     } on DioException catch (e) {
//       throw Exception('Register error: ${e.message}');
//     }
//   }

//   @override
//   Future<AuthResponseModel> getCurrentUser() async {
//     try {
//       final response = await _apiClient.get(ApiEndpoints.me);

//       if (response.statusCode == 200) {
//         return AuthResponseModel.fromJson(response.data);
//       } else {
//         throw Exception('Failed to get current user: ${response.statusMessage}');
//       }
//     } on DioException catch (e) {
//       throw Exception('Get current user error: ${e.message}');
//     }
//   }
// }
