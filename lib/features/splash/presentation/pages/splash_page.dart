import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nutrisphere_flutter/app/routes/app_routes.dart';
import 'package:nutrisphere_flutter/core/services/storage/user_session_service.dart';
import 'package:nutrisphere_flutter/features/home/presentation/pages/dashboard_page.dart';
import 'package:nutrisphere_flutter/features/onboarding/presentation/pages/onboarding_page.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    final userSessionService = ref.read(userSessionServiceProvider);
    final isLoggedIn = userSessionService.isLoggedIn();

    if (isLoggedIn) {
      AppRoutes.pushReplacement(context, const DashboardPage());
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
              "assets/images/bg.svg",
              fit: BoxFit.cover,
              placeholderBuilder: (_) => const SizedBox.expand(),
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
