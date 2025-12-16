import 'package:flutter/material.dart';
import 'package:nutrisphere_flutter/screens/bottom_navigation_screen.dart';
import 'package:nutrisphere_flutter/screens/forgot_password_screen.dart';
import 'package:nutrisphere_flutter/screens/login_screen.dart';
import 'package:nutrisphere_flutter/screens/onboarding_screen.dart';
import 'package:nutrisphere_flutter/screens/register_screen.dart';
import 'package:nutrisphere_flutter/screens/splash_screen.dart';

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
        '/dashboard': (context) => const BottomNavigationScreen(),
      },
    );
  }
}
