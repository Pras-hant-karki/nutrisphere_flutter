import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:nutrisphere_flutter/features/notifications/data/models/notification_model.dart';
import 'package:nutrisphere_flutter/features/notifications/data/services/notification_api_service.dart';

/// Provider for the notification list
final notificationsProvider = StateNotifierProvider<NotificationsNotifier,
    AsyncValue<List<NotificationModel>>>((ref) {
  final service = ref.read(notificationApiServiceProvider);
  return NotificationsNotifier(service);
});

/// Provider for unread count (auto-refreshes)
final unreadCountProvider = StateProvider<int>((ref) => 0);

class NotificationsNotifier
    extends StateNotifier<AsyncValue<List<NotificationModel>>> {
  final NotificationApiService _service;

  NotificationsNotifier(this._service)
      : super(const AsyncValue.loading()) {
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    try {
      state = const AsyncValue.loading();
      final notifications = await _service.getNotifications();
      if (mounted) {
        state = AsyncValue.data(notifications);
      }
    } catch (e, st) {
      if (mounted) {
        state = AsyncValue.error(e, st);
      }
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _service.markAsRead(notificationId);
      // Update local state
      state.whenData((notifications) {
        final updated = notifications.map((n) {
          if (n.id == notificationId) {
            return NotificationModel(
              id: n.id,
              recipientId: n.recipientId,
              type: n.type,
              title: n.title,
              message: n.message,
              isRead: true,
              senderName: n.senderName,
              relatedId: n.relatedId,
              createdAt: n.createdAt,
            );
          }
          return n;
        }).toList();
        state = AsyncValue.data(updated);
      });
    } catch (e) {
      // Silently fail, notification will be marked on next fetch
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _service.markAllAsRead();
      state.whenData((notifications) {
        final updated = notifications
            .map((n) => NotificationModel(
                  id: n.id,
                  recipientId: n.recipientId,
                  type: n.type,
                  title: n.title,
                  message: n.message,
                  isRead: true,
                  senderName: n.senderName,
                  relatedId: n.relatedId,
                  createdAt: n.createdAt,
                ))
            .toList();
        state = AsyncValue.data(updated);
      });
    } catch (e) {
      // Silently fail
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await _service.deleteNotification(notificationId);
      state.whenData((notifications) {
        final updated =
            notifications.where((n) => n.id != notificationId).toList();
        state = AsyncValue.data(updated);
      });
    } catch (e) {
      // Silently fail
    }
  }
}
