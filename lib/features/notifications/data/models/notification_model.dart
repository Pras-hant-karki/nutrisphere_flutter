class NotificationModel {
  final String id;
  final String recipientId;
  final String type;
  final String title;
  final String message;
  final bool isRead;
  final String? senderName;
  final String? senderProfilePicture;
  final String? relatedId;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.recipientId,
    required this.type,
    required this.title,
    required this.message,
    required this.isRead,
    this.senderName,
    this.senderProfilePicture,
    this.relatedId,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final metadata = json['metadata'] as Map<String, dynamic>?;
    return NotificationModel(
      id: json['_id'] ?? '',
      recipientId: json['recipientId'] ?? '',
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      isRead: json['isRead'] ?? false,
      senderName: metadata?['senderName'],
      senderProfilePicture: metadata?['senderProfilePicture'],
      relatedId: metadata?['relatedId'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  /// Get the icon based on notification type
  String get typeLabel {
    switch (type) {
      case 'new_post':
        return 'New Post';
      case 'new_session':
        return 'New Session';
      case 'trainer_update':
        return 'Trainer Update';
      case 'appointment_request':
        return 'Appointment';
      case 'plan_request':
        return 'Plan Request';
      default:
        return 'Notification';
    }
  }

  /// Get time ago string
  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }
}
