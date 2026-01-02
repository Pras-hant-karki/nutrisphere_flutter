import 'package:flutter/material.dart';
import 'app_colors.dart';

extension ThemeColorsExtension on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  Color get textPrimary =>
      isDarkMode ? AppColors.darkTextPrimary : AppColors.textPrimary;

  Color get textSecondary =>
      isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary;

  Color get backgroundColor =>
      isDarkMode ? AppColors.darkBackground : AppColors.background;

  Color get surfaceColor =>
      isDarkMode ? AppColors.darkSurface : AppColors.surface;

  Color get inputFillColor =>
      isDarkMode ? AppColors.darkInputFill : AppColors.inputFill;

  Color get borderColor =>
      isDarkMode ? AppColors.darkBorder : AppColors.border;

  List<BoxShadow> get softShadow =>
      isDarkMode ? AppColors.darkSoftShadow : AppColors.softShadow;
}
