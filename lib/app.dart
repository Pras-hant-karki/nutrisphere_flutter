import 'package:flutter/material.dart';
import 'package:nutrisphere_flutter/dashboard_screen.dart';
import 'package:nutrisphere_flutter/forgot_password_screen.dart';
import 'package:nutrisphere_flutter/login_screen.dart';
import 'package:nutrisphere_flutter/onboarding_screen.dart';
import 'package:nutrisphere_flutter/register_screen.dart';
import 'package:nutrisphere_flutter/splash_screen.dart';

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
        '/login': (context) => const LoginScreen(),
        '/forgot': (context) => const ForgotPasswordScreen(),
        '/register': (context) => const RegisterScreen(),
        '/dashboard': (context) => const DashboardScreen(),
      },
    );
  }
}
