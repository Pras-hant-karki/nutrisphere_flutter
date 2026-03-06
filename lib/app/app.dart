import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import 'package:nutrisphere_flutter/features/admin/presentation/pages/admin_dashboard_page.dart';
import 'package:nutrisphere_flutter/features/admin/presentation/pages/admin_bottom_navigation_page.dart';
import 'package:nutrisphere_flutter/app/theme/theme_data.dart';
import 'package:nutrisphere_flutter/core/providers/sensor_provider.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  StreamSubscription<bool>? _earSub;
  StreamSubscription<bool>? _safetySub;
  DateTime _lastEarNoticeAt =
      DateTime.fromMillisecondsSinceEpoch(0);
  bool _isAppLockedForSafety = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final sensorService = ref.read(sensorServiceProvider);

      _earSub = sensorService.earStream.listen((atEar) {
        if (!atEar) return;

        final now = DateTime.now();
        if (now.difference(_lastEarNoticeAt) < const Duration(seconds: 8)) {
          return;
        }
        _lastEarNoticeAt = now;

        final context = _navigatorKey.currentContext;
        if (context == null || !mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ear detection active'),
            duration: Duration(seconds: 2),
          ),
        );
      });

      _safetySub = sensorService.safetyStream.listen((shouldLock) {
        if (!mounted) return;
        setState(() {
          _isAppLockedForSafety = shouldLock;
        });
      });
    });
  }

  @override
  void dispose() {
    _earSub?.cancel();
    _safetySub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Keep sensor service alive app-wide so streams actually start.
    ref.watch(sensorServiceProvider);

    return MaterialApp(
      navigatorKey: _navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: getApplicationTheme(),
      builder: (context, child) {
        return Stack(
          children: [
            if (child != null) child,
            if (_isAppLockedForSafety)
              _SafetyLockOverlay(
                onUnlock: () {
                  setState(() {
                    _isAppLockedForSafety = false;
                  });
                },
              ),
          ],
        );
      },
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
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/admin-dashboard': (context) => const AdminDashboardPage(),
        '/admin-bottom-navigation': (context) => const AdminBottomNavigationPage(),
      },
    );
  }
}

class _SafetyLockOverlay extends StatelessWidget {
  const _SafetyLockOverlay({required this.onUnlock});

  final VoidCallback onUnlock;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.86),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.lock,
                  color: Colors.white,
                  size: 68,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Safety lock enabled',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Device stayed flat on floor.\nTap unlock after picking it up.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: onUnlock,
                  icon: const Icon(Icons.lock_open),
                  label: const Text('Unlock App'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
