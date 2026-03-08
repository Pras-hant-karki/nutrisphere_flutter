import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutrisphere_flutter/core/api/api_client.dart';
import 'package:nutrisphere_flutter/core/api/api_endpoints.dart';
import 'package:nutrisphere_flutter/features/admin/data/models/member_model.dart';

final userManagementServiceProvider = Provider<UserManagementService>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return UserManagementService(apiClient: apiClient);
});

class UserManagementService {
  final ApiClient apiClient;

  UserManagementService({required this.apiClient});

  /// Fetch all users
  Future<List<MemberModel>> getAllUsers() async {
    try {
      final response = await apiClient.get(ApiEndpoints.adminUsers);
      final data = response.data['data'] as List;
      return data
          .map((e) => MemberModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching users: $e');
      rethrow;
    }
  }

  /// Delete a user by ID
  Future<void> deleteUser(String userId) async {
    try {
      await apiClient.delete(ApiEndpoints.adminUserById(userId));
    } catch (e) {
      debugPrint('Error deleting user: $e');
      rethrow;
    }
  }
}
