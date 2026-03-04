import 'dart:io';

import 'package:flutter/foundation.dart';

class ApiEndpoints {
  ApiEndpoints._();

  static const String _configuredBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  static const bool _useAndroidEmulatorHost = bool.fromEnvironment(
    'USE_ANDROID_EMULATOR_HOST',
    defaultValue: false,
  );

  // Set this to your machine LAN IP when testing from a real Android device.
  static const String compIpAddress = '172.25.0.110';

  static String get baseUrl {
    if (_configuredBaseUrl.isNotEmpty) {
      return _configuredBaseUrl;
    }

    if (kIsWeb) {
      final host = Uri.base.host.isNotEmpty ? Uri.base.host : 'localhost';
      final scheme = Uri.base.scheme.isNotEmpty ? Uri.base.scheme : 'http';
      return '$scheme://$host:5000';
    } else if (Platform.isAndroid) {
      return _useAndroidEmulatorHost
          ? 'http://10.0.2.2:5000'
          : 'http://$compIpAddress:5000';
    } else if (Platform.isIOS) {
      return 'http://localhost:5000';
    } else {
      return 'http://localhost:5000';
    }
  }

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // ============ Auth Endpoints ============
  static const String login = '/api/auth/login';
  static const String register = '/api/auth/register';
  static const String me = '/api/auth/me';
  static const String uploadImage = '/api/auth/upload-profile-picture';
  static const String uploadProfilePicture = '/api/auth/profile-picture';
  static String updateProfile(String id) => '/api/auth/$id';

  // ============ Fitness Endpoints ============
  static const String fitness = '/api/fitness';
  static String fitnessById(String id) => '/api/fitness/$id';
  static const String fitnessUploadPhoto = '/api/fitness/upload-photo';
  static const String fitnessUploadVideo = '/api/fitness/upload-video';

  // ============ Admin Endpoints ============
  static const String adminUsers = '/api/admin/users';
  static String adminUserById(String id) => '/api/admin/users/$id';

  // ============ Admin Bio Endpoints ============
  static const String adminBio = '/api/admin/bio';
  static const String adminBioUploadImage = '/api/admin/bio/upload-image';
  static const String trainerInfo = '/api/admin/trainer-info';

  // ============ Plan Request Endpoints ============
  static const String planRequests = '/api/plan-requests';
  static const String myPlanRequests = '/api/plan-requests/my-requests';
  static const String adminPlanRequests = '/api/plan-requests/admin';
  static String adminPlanRequestById(String id) =>
      '/api/plan-requests/admin/$id';
  static String approvePlanRequest(String id) =>
      '/api/plan-requests/admin/$id/approve';
  static String rejectPlanRequest(String id) =>
      '/api/plan-requests/admin/$id/reject';

  // ============ Appointment Endpoints ============
  static const String appointments = '/api/appointments';
  static const String myAppointments = '/api/appointments/my-appointments';
  static const String adminAppointments = '/api/appointments/admin';
  static String adminAppointmentById(String id) =>
      '/api/appointments/admin/$id';
  static String approveAppointment(String id) =>
      '/api/appointments/admin/$id/approve';
  static String rescheduleAppointment(String id) =>
      '/api/appointments/admin/$id/reschedule';
  static String cancelAppointment(String id) =>
      '/api/appointments/admin/$id/cancel';

  // ============ Notification Endpoints ============
  static const String notifications = '/api/notifications';
  static const String notificationsUnreadCount =
      '/api/notifications/unread-count';
  static const String notificationsReadAll = '/api/notifications/read-all';
  static String notificationMarkRead(String id) =>
      '/api/notifications/$id/read';
  static String notificationDelete(String id) => '/api/notifications/$id';

  // ============ Session Endpoints ============
  static const String sessions = '/api/sessions';
  static const String adminSessions = '/api/sessions/admin';
  static String adminSessionById(String id) => '/api/sessions/admin/$id';
  static String toggleAdminSession(String id) =>
      '/api/sessions/admin/$id/toggle';
}
