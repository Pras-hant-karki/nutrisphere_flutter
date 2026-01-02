import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary – Nutrition Green
  static const Color primary = Color(0xFF2E7D32);
  static const Color primaryDark = Color(0xFF1B5E20);
  static const Color primaryLight = Color(0xFF66BB6A);

  // Secondary – Energy Orange
  static const Color secondary = Color(0xFFFF9800);
  static const Color secondaryLight = Color(0xFFFFB74D);

  // Accent – Fresh Teal
  static const Color accent = Color(0xFF26A69A);

  // Backgrounds
  static const Color background = Color(0xFFF4F7F4);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F8E9);
  static const Color inputFill = Color(0xFFF0F4F1);

  // Text
  static const Color textPrimary = Color(0xFF1C1C1C);
  static const Color textSecondary = Color(0xFF616161);
  static const Color textMuted = Color(0xFF9E9E9E);

  // Borders
  static const Color border = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFEAEAEA);

  // Status
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFA726);
  static const Color error = Color(0xFFE53935);
  static const Color info = Color(0xFF43A047);

  // Auth
  static const Color authPrimary = primary;

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryLight, primary],
  );

  static const LinearGradient energyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondaryLight, secondary],
  );

  // Shadows
  static const List<BoxShadow> softShadow = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  // Dark Theme
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkInputFill = Color(0xFF2A2A2A);

  static const Color darkTextPrimary = Color(0xFFE0E0E0);
  static const Color darkTextSecondary = Color(0xFFBDBDBD);

  static const Color darkBorder = Color(0xFF333333);

  static const List<BoxShadow> darkSoftShadow = [
    BoxShadow(
      color: Color(0x33000000),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];
}
