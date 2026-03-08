import 'package:flutter/material.dart';
import 'package:nutrisphere_flutter/features/admin/presentation/pages/admin_appointment_page.dart';
import 'package:nutrisphere_flutter/features/admin/presentation/pages/admin_bio_page.dart';
import 'package:nutrisphere_flutter/features/admin/presentation/pages/admin_bottom_navigation_page.dart';
import 'package:nutrisphere_flutter/features/admin/presentation/pages/admin_dashboard_page.dart';
import 'package:nutrisphere_flutter/features/admin/presentation/pages/admin_home_page.dart';
import 'package:nutrisphere_flutter/features/admin/presentation/pages/admin_profile_page.dart';
import 'package:nutrisphere_flutter/features/admin/presentation/pages/session_manage_page.dart';
import 'package:nutrisphere_flutter/features/admin/presentation/pages/user_management_page.dart';
import 'package:nutrisphere_flutter/features/admin/presentation/pages/view_appointment_page.dart';
import 'package:nutrisphere_flutter/features/admin/presentation/pages/view_request_page.dart';
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
  static const String adminDashboard = '/admin-dashboard';
  static const String adminBottomNavigation = '/admin-bottom-navigation';
  static const String adminHome = '/admin-home';
  static const String adminAppointment = '/admin-appointment';
  static const String adminProfile = '/admin-profile';
  static const String viewRequest = '/view-request';
  static const String viewAppointment = '/view-appointment';
  static const String sessionManage = '/session-manage';
  static const String adminBio = '/admin-bio';
  static const String userManagement = '/user-management';

  /// Route map
  static final Map<String, WidgetBuilder> routes = {
    splash: (context) => const SplashScreen(),
    login: (context) => const LoginPage(),
    signup: (context) => const RegisterPage(),
    dashboard: (context) => const DashboardPage(),
    onboarding: (context) => const OnboardingScreen(),
    forgotPassword: (context) => const ForgotPasswordScreen(),
    // setting: (context) => const SettingPage(),
    adminDashboard: (context) => const AdminDashboardPage(),
    adminBottomNavigation: (context) => const AdminBottomNavigationPage(),
    adminHome: (context) => const AdminHomePage(),
    adminAppointment: (context) => const AdminAppointmentPage(),
    adminProfile: (context) => const AdminProfilePage(),
    viewRequest: (context) => const ViewRequestPage(),
    viewAppointment: (context) => const ViewAppointmentPage(),
    sessionManage: (context) => const SessionManagePage(),
    adminBio: (context) => const AdminBioPage(),
    userManagement: (context) => const UserManagementPage(),
  };
}