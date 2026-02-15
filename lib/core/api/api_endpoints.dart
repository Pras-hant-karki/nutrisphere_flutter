import 'dart:io';

import 'package:flutter/foundation.dart';

class ApiEndpoints {
  ApiEndpoints._();

  static const bool isPhysicalDevice = false;

  static const String compIpAddress = "192.168.1.1";

  static String get baseUrl {
    if (isPhysicalDevice) {
      return 'http://$compIpAddress:5000';
    }
    // yadi android
    if (kIsWeb) {
      return 'http://localhost:5000';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:5000';
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
}

