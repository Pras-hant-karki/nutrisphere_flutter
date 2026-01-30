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

  // ============ Fitness Endpoints ============
  static const String fitness = '/api/fitness';
  static String fitnessById(String id) => '/api/fitness/$id';
  static const String fitnessUploadPhoto = '/api/fitness/upload-photo';
  static const String fitnessUploadVideo = '/api/fitness/upload-video';
}

