import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutrisphere_flutter/core/api/api_client.dart';
import 'package:nutrisphere_flutter/core/api/api_endpoints.dart';
import 'package:nutrisphere_flutter/core/services/storage/token_service.dart';
import 'package:nutrisphere_flutter/features/profile/data/datasources/profile_datasource.dart';

final profileRemoteDatasourceProvider = Provider<IProfileRemoteDataSource>((ref) {
  return ProfileRemoteDatasource(
    apiClient: ref.read(apiClientProvider),
    tokenService: ref.read(tokenServiceProvider),
  );
});

class ProfileRemoteDatasource implements IProfileRemoteDataSource {
  final ApiClient _apiClient;
  final TokenService _tokenService;

  ProfileRemoteDatasource({
    required ApiClient apiClient,
    required TokenService tokenService,
  }) : _apiClient = apiClient,
       _tokenService = tokenService;

  @override
  Future<String> uploadProfilePicture(File image) async {
    final fileName = image.path.split('/').last;

    final token = _tokenService.getToken();
    if (token == null) {
      throw Exception("Token not found. Please login again.");
    }

    final formData = FormData.fromMap({
      "profilePicture": await MultipartFile.fromFile(image.path, filename: fileName),
    });

    final response = await _apiClient.uploadFile(
      ApiEndpoints.uploadProfilePicture,
      formData: formData,
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
      ),
    );

    return response.data['profilePictureUrl'];
  }
}
