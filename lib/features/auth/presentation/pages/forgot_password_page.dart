import 'package:flutter/material.dart';
import 'package:nutrisphere_flutter/app/theme/app_colors.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const SizedBox(height: 20),

              // Back arrow
              IconButton(
                onPressed: () => Navigator.pushReplacementNamed(context, "/login"),
                icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
              ),

              const SizedBox(height: 10),

              const Center(
                child: Text(
                  "Forgot password",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),

              const SizedBox(height: 60),

              TextField(
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: "Email",
                  labelStyle: const TextStyle(color: AppColors.textSecondary),
                  hintText: "Enter your email",
                  hintStyle: const TextStyle(color: AppColors.textMuted),
                  prefixIcon: const Icon(Icons.email_outlined, color: AppColors.textSecondary),
                  filled: true,
                  fillColor: AppColors.inputFill,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.gold, width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.error),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.error, width: 2),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {},
                  child: const Text(
                    "Reset password",
                    style: TextStyle(fontSize: 18, color: AppColors.textPrimary),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Go back link
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.pushReplacementNamed(context, "/login"),
                  child: const Text(
                    "←  Go back",
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
