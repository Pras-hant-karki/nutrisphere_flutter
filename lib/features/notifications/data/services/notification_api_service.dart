import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutrisphere_flutter/core/api/api_client.dart';
import 'package:nutrisphere_flutter/core/api/api_endpoints.dart';
import 'package:nutrisphere_flutter/features/notifications/data/models/notification_model.dart';

final notificationApiServiceProvider =
    Provider<NotificationApiService>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return NotificationApiService(apiClient: apiClient);
});

class NotificationApiService {
  final ApiClient apiClient;

  NotificationApiService({required this.apiClient});

  /// Fetch all notifications for the authenticated user
  Future<List<NotificationModel>> getNotifications() async {
    try {
      final response = await apiClient.get(ApiEndpoints.notifications);
      final data = response.data['data'] as List;
      return data
          .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
      rethrow;
    }
  }

  /// Get unread count
  Future<int> getUnreadCount() async {
    try {
      final response =
          await apiClient.get(ApiEndpoints.notificationsUnreadCount);
      return response.data['data']['count'] as int;
    } catch (e) {
      debugPrint('Error fetching unread count: $e');
      return 0;
    }
  }

  /// Mark a single notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await apiClient
          .put(ApiEndpoints.notificationMarkRead(notificationId));
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
      rethrow;
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      await apiClient.put(ApiEndpoints.notificationsReadAll);
    } catch (e) {
      debugPrint('Error marking all as read: $e');
      rethrow;
    }
  }

  /// Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await apiClient
          .delete(ApiEndpoints.notificationDelete(notificationId));
    } catch (e) {
      debugPrint('Error deleting notification: $e');
      rethrow;
    }
  }
}
