import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutrisphere_flutter/core/api/api_client.dart';
import 'package:nutrisphere_flutter/core/api/api_endpoints.dart';
import 'package:nutrisphere_flutter/features/admin/data/models/bio_entry_model.dart';
import 'package:nutrisphere_flutter/features/admin/data/models/trainer_info_model.dart';

final bioServiceProvider = Provider<BioService>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return BioService(apiClient: apiClient);
});

class BioService {
  final ApiClient apiClient;

  BioService({required this.apiClient});

  /// Fetch bio entries for admin
  Future<List<BioEntryModel>> getBio() async {
    try {
      final response = await apiClient.get(ApiEndpoints.adminBio);
      final data = response.data['data'] as List;
      return data
          .map((e) => BioEntryModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching bio: $e');
      rethrow;
    }
  }

  /// Save bio entries
  Future<void> saveBio(List<BioEntryModel> entries) async {
    try {
      await apiClient.put(
        ApiEndpoints.adminBio,
        data: {
          'bio': entries.map((e) => e.toJson()).toList(),
        },
      );
    } catch (e) {
      debugPrint('Error saving bio: $e');
      rethrow;
    }
  }

  /// Upload bio image
  Future<String> uploadBioImage(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(filePath),
      });
      final response = await apiClient.uploadFile(
        ApiEndpoints.adminBioUploadImage,
        formData: formData,
      );
      return response.data['data']['imageUrl'] as String;
    } catch (e) {
      debugPrint('Error uploading bio image: $e');
      rethrow;
    }
  }

  /// Fetch trainer info (for users)
  Future<TrainerInfoModel> getTrainerInfo() async {
    try {
      final response = await apiClient.get(ApiEndpoints.trainerInfo);
      return TrainerInfoModel.fromJson(
          response.data['data'] as Map<String, dynamic>);
    } catch (e) {
      debugPrint('Error fetching trainer info: $e');
      rethrow;
    }
  }
}
