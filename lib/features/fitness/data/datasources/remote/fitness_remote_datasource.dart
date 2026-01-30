import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutrisphere_flutter/core/api/api_client.dart';
import 'package:nutrisphere_flutter/core/api/api_endpoints.dart';
import 'package:nutrisphere_flutter/core/services/storage/token_service.dart';
import 'package:nutrisphere_flutter/features/fitness/data/datasources/fitness_datasource.dart';
import 'package:nutrisphere_flutter/features/fitness/data/models/fitness_api_model.dart';

final fitnessRemoteDatasourceProvider = Provider<IFitnessRemoteDataSource>((ref) {
  return FitnessRemoteDatasource(
    apiClient: ref.read(apiClientProvider),
    tokenService: ref.read(tokenServiceProvider),
  );
});

class FitnessRemoteDatasource implements IFitnessRemoteDataSource {
  final ApiClient _apiClient;
  final TokenService _tokenService;

  FitnessRemoteDatasource({
    required ApiClient apiClient,
    required TokenService tokenService,
  }) : _apiClient = apiClient,
       _tokenService = tokenService;

  @override
  Future<FitnessApiModel> createFitness(FitnessApiModel fitness) async {
    final token = await _tokenService.getToken();
    final response = await _apiClient.post(
      ApiEndpoints.fitness,
      data: fitness.toJson(),
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    return FitnessApiModel.fromJson(response.data['data']);
  }

  @override
  Future<List<FitnessApiModel>> getAllFitness() async {
    final response = await _apiClient.get(ApiEndpoints.fitness);
    final data = response.data['data'] as List;
    return data.map((json) => FitnessApiModel.fromJson(json)).toList();
  }

  @override
  Future<FitnessApiModel> getFitnessById(String fitnessId) async {
    final response = await _apiClient.get(ApiEndpoints.fitnessById(fitnessId));
    return FitnessApiModel.fromJson(response.data['data']);
  }

  @override
  Future<List<FitnessApiModel>> getFitnessByCategory(String category) async {
    final response = await _apiClient.get(
      ApiEndpoints.fitness,
      queryParameters: {'category': category},
    );
    final data = response.data['data'] as List;
    return data.map((json) => FitnessApiModel.fromJson(json)).toList();
  }

  @override
  Future<bool> updateFitness(FitnessApiModel fitness) async {
    final token = await _tokenService.getToken();
    await _apiClient.put(
      ApiEndpoints.fitnessById(fitness.fitnessId!),
      data: fitness.toJson(),
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return true;
  }

  @override
  Future<bool> deleteFitness(String fitnessId) async {
    final token = await _tokenService.getToken();
    await _apiClient.delete(
      ApiEndpoints.fitnessById(fitnessId),
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return true;
  }
  
  // @override
  // Future<String> uploadPhoto(File photo) async {
  //   final fileName = photo.path.split('/').last;
  //   final formData = FormData.fromMap({
  //     "fitnessPhoto": await MultipartFile.fromFile(photo.path, filename: fileName),
  //   });
  //   // Get token from token service
  //   final token = await _tokenService.getToken();
  //   final response = await _apiClient.uploadFile(
  //     ApiEndpoints.fitnessUploadPhoto,
  //     formData: formData,
  //     options: Options(headers: {'Authorization': 'Bearer $token'}),
  //   );

  //   return response.data['data'];
  // }
  
    @override
    Future<String> uploadPhoto(File photo) async {
    final fileName = photo.path.split('/').last;

    final token = await _tokenService.getToken();
    if (token == null) {
      throw Exception("Token not found. Please login again.");
    }

    final formData = FormData.fromMap({
      "fitnessPhoto": await MultipartFile.fromFile(photo.path, filename: fileName),
    });

    final response = await _apiClient.uploadFile(
      ApiEndpoints.fitnessUploadPhoto,
      formData: formData,
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
      ),
    );

    return response.data['data'];
  }


  @override
  Future<String> uploadVideo(File video) async {
    final fileName = video.path.split('/').last;
    final formData = FormData.fromMap({
      'fitnessVideo': await MultipartFile.fromFile(video.path, filename: fileName),
    });
    // Get token from token service
    final token = await _tokenService.getToken();
    final response = await _apiClient.uploadFile(
      ApiEndpoints.fitnessUploadVideo,
      formData: formData,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    return response.data['data'];
  }
}