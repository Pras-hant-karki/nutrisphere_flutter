import 'package:flutter/material.dart';
import 'package:nutrisphere_flutter/features/appointment/presentation/pages/appointment_page.dart';
import 'package:nutrisphere_flutter/features/dashboard/presentation/pages/bottom_navigation_page.dart';
import 'package:nutrisphere_flutter/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:nutrisphere_flutter/features/auth/presentation/pages/login_page.dart';
import 'package:nutrisphere_flutter/features/fitness/presentation/pages/fitness_guide_page.dart';
import 'package:nutrisphere_flutter/features/home/presentation/pages/home_page.dart';
import 'package:nutrisphere_flutter/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:nutrisphere_flutter/features/auth/presentation/pages/register_page.dart';
import 'package:nutrisphere_flutter/features/profile/presentation/pages/profile_page.dart';
import 'package:nutrisphere_flutter/features/splash/presentation/pages/splash_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginPage(),
        '/forgot': (context) => const ForgotPasswordScreen(),
        '/register': (context) => const RegisterPage(),
        '/dashboard': (context) => const BottomNavigationScreen(),
        '/home': (context) => const HomeScreen(),
        '/fitness': (context) => const FitnessGuideScreen(),
        '/appointments': (context) => const AppointmentScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}
