import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nutrisphere_flutter/app/routes/app_routes.dart';
import 'package:nutrisphere_flutter/core/services/storage/user_session_service.dart';
import 'package:nutrisphere_flutter/features/home/presentation/pages/home_page.dart';
import 'package:nutrisphere_flutter/features/onboarding/presentation/pages/onboarding_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  get ref => null;

  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future <void> _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 3));
    // Navigate to the next page, e.g., HomePage or LoginPage
    // Navigator.pushReplacementNamed(context, '/home');
    if (!mounted) return;
    // check if user is already logged in
    final UserSessionService = ref.read(userSessionServiceProvider);
    final isLoggedIn = UserSessionService.isLoggedIn();

    if (isLoggedIn) {
      AppRoutes.pushReplacement(context, const HomeScreen());
    } else {
      AppRoutes.pushReplacement(context, const OnboardingScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [

          Positioned.fill(
            child: SvgPicture.asset(
              "assets/images/bg.svg", // vector image
              fit: BoxFit.cover,
            ),
          ),

          Container(
            color: const Color(0xFF04A4A4).withOpacity(0.92),
          ),

          Center(
            child: SizedBox(
              width: 320,
              child: Image.asset(
                "assets/images/logo.png",
              ),
            ),
          ),
        ],
      ),
    );
  }
}
