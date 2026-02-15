import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutrisphere_flutter/core/api/api_client.dart';
import 'package:nutrisphere_flutter/core/api/api_endpoints.dart';
import 'package:nutrisphere_flutter/features/admin/data/models/plan_request_model.dart';

final planRequestServiceProvider = Provider<PlanRequestService>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return PlanRequestService(apiClient: apiClient);
});

class PlanRequestService {
  final ApiClient apiClient;

  PlanRequestService({required this.apiClient});

  /// Fetch all plan requests (admin)
  Future<List<PlanRequestModel>> getAllRequests({bool pendingOnly = false}) async {
    try {
      final queryParams = pendingOnly ? {'pending': 'true'} : null;
      final response = await apiClient.get(
        ApiEndpoints.adminPlanRequests,
        queryParameters: queryParams,
      );
      final data = response.data['data'] as List;
      return data
          .map((e) => PlanRequestModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching plan requests: $e');
      rethrow;
    }
  }

  /// Approve a plan request with a file upload
  Future<void> approveWithFile(String requestId, String filePath) async {
    try {
      final formData = FormData.fromMap({
        'planFile': await MultipartFile.fromFile(filePath),
      });
      await apiClient.uploadFile(
        ApiEndpoints.approvePlanRequest(requestId),
        formData: formData,
      );
    } catch (e) {
      debugPrint('Error approving request with file: $e');
      rethrow;
    }
  }

  /// Approve a plan request with a link
  Future<void> approveWithLink(String requestId, String link) async {
    try {
      await apiClient.put(
        ApiEndpoints.approvePlanRequest(requestId),
        data: {'link': link},
      );
    } catch (e) {
      debugPrint('Error approving request with link: $e');
      rethrow;
    }
  }

  /// Reject a plan request with a reason
  Future<void> rejectRequest(String requestId, String reason) async {
    try {
      await apiClient.put(
        ApiEndpoints.rejectPlanRequest(requestId),
        data: {'reason': reason},
      );
    } catch (e) {
      debugPrint('Error rejecting request: $e');
      rethrow;
    }
  }

  /// User submits a plan request
  Future<void> submitRequest(Map<String, dynamic> data) async {
    try {
      await apiClient.post(
        ApiEndpoints.planRequests,
        data: data,
      );
    } catch (e) {
      debugPrint('Error submitting plan request: $e');
      rethrow;
    }
  }

  /// User gets their own requests
  Future<List<PlanRequestModel>> getMyRequests() async {
    try {
      final response = await apiClient.get(ApiEndpoints.myPlanRequests);
      final data = response.data['data'] as List;
      return data
          .map((e) => PlanRequestModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching my plan requests: $e');
      rethrow;
    }
  }
}
