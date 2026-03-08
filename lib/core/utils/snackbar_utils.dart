import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

class SnackbarUtils {
  static void showError(BuildContext context, String message,
      {Color textColor = Colors.white}) {
    _showSnackBar(
      context,
      message,
      backgroundColor: AppColors.error,
      icon: Icons.error_outline_rounded,
      textColor: textColor,
    );
  }

  static void showSuccess(BuildContext context, String message,
      {Color textColor = Colors.white}) {
    _showSnackBar(
      context,
      message,
      backgroundColor: AppColors.success,
      icon: Icons.check_circle_outline_rounded,
      textColor: textColor,
    );
  }

  static void showInfo(BuildContext context, String message) {
    _showSnackBar(
      context,
      message,
      backgroundColor: AppColors.primary,
      icon: Icons.info_outline_rounded,
    );
  }

  static void showWarning(BuildContext context, String message) {
    _showSnackBar(
      context,
      message,
      backgroundColor: const Color(0xFFFFA726),
      icon: Icons.warning_amber_rounded,
    );
  }

  static void _showSnackBar(
    BuildContext context,
    String message, {
    required Color backgroundColor,
    required IconData icon,
    Color textColor = Colors.white,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: textColor, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
