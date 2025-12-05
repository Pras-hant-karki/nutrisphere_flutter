import 'dart:async';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/onboarding');
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/images/bg.png",
              fit: BoxFit.cover,
              ),
            ),

            Container(
              color: Color(0xFF04A4A4).withOpacity(0.92),
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