import 'package:flutter/material.dart';
import 'app_colors.dart';

extension ThemeColorsExtension on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  Color get textPrimary => AppColors.textPrimary;

  Color get textSecondary => AppColors.textSecondary;

  Color get backgroundColor => AppColors.background;

  Color get surfaceColor => AppColors.cardBackground;

  Color get inputFillColor => AppColors.inputFill;

  Color get borderColor => AppColors.border;

  List<BoxShadow> get softShadow => AppColors.softShadow;
}
