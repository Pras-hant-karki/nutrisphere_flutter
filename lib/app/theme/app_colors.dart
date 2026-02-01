import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary – Nutrition Green
  static const Color primary = Color(0xFF2ECC71);

  // Secondary – Dark Green
  static const Color secondaryDark = Color(0xFF1E3D2B);

  // Backgrounds
  static const Color background = Color(0xFF0F1310);
  static const Color cardBackground = Color(0xFF171C18);
  static const Color inputFill = Color(0xFF1B211D);

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF9FB3A6);
  static const Color textMuted = Color(0xFF7C8C83);

  // Borders
  static const Color border = Color(0xFF26322B);

  // Accents
  static const Color gold = Color(0xFFD4AF37);
  static const Color silver = Color(0xFFC0C0C0);

  // Status
  static const Color success = Color(0xFF2ECC71);
  static const Color error = Color(0xFFE53935);

  // Shadows
  static const List<BoxShadow> softShadow = [
    BoxShadow(
      color: Color(0x66000000),
      blurRadius: 16,
      offset: Offset(0, 8),
    ),
  ];
}
