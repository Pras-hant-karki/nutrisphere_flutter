import 'package:flutter/material.dart';
import 'package:nutrisphere_flutter/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:nutrisphere_flutter/features/auth/presentation/pages/login_page.dart';
import 'package:nutrisphere_flutter/features/auth/presentation/pages/register_page.dart';
import 'package:nutrisphere_flutter/features/home/presentation/pages/dashboard_page.dart';
import 'package:nutrisphere_flutter/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:nutrisphere_flutter/features/splash/presentation/pages/splash_page.dart';

/// Centralized route definitions for the application
class AppRoutes {
  /// Route names
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String dashboard = '/dashboard';
  static const String onboarding = '/onboarding';
  static const String forgotPassword = '/forgot-password';
  // static const String setting = '/setting';
  // static const String adminDashboard = '/admin-dashboard';

  /// Route map
  static final Map<String, WidgetBuilder> routes = {
    splash: (context) => const SplashScreen(),
    login: (context) => const LoginPage(),
    signup: (context) => const RegisterPage(),
    dashboard: (context) => const DashboardPage(),
    onboarding: (context) => const OnboardingScreen(),
    forgotPassword: (context) => const ForgotPasswordScreen(),
    // setting: (context) => const SettingPage(),
    // adminDashboard: (context) => const AdminDashboardPage(),
  };
}