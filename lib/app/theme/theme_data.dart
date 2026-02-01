import 'package:flutter/material.dart';
import 'package:nutrisphere_flutter/app/theme/app_colors.dart';

ThemeData getApplicationTheme() {
  return ThemeData(
    useMaterial3: true,
    fontFamily: "OpenSans Regular",
    scaffoldBackgroundColor: AppColors.background,

    colorScheme: ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.primary,
      onPrimary: AppColors.textPrimary,
      secondary: AppColors.secondaryDark,
      onSecondary: AppColors.textPrimary,
      error: Colors.redAccent,
      onError: AppColors.textPrimary,
      background: AppColors.background,
      onBackground: AppColors.textPrimary,
      surface: AppColors.cardBackground,
      onSurface: AppColors.textPrimary,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: AppColors.textPrimary),
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
        fontFamily: "Montserrat Bold",
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.inputFill,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      hintStyle: const TextStyle(
        fontSize: 14,
        color: AppColors.textMuted,
      ),
      labelStyle: const TextStyle(
        fontSize: 14,
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w600,
      ),
    ),

    textTheme: const TextTheme(
      bodyMedium: TextStyle(
        fontSize: 14,
        fontFamily: 'OpenSans Regular',
        color: AppColors.textSecondary,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontFamily: 'OpenSans Regular',
        color: AppColors.textPrimary,
      ),
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        fontFamily: 'Montserrat Bold',
        color: AppColors.textPrimary,
      ),
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.background,
      selectedItemColor: AppColors.textPrimary,
      unselectedItemColor: AppColors.secondaryDark,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textPrimary,
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          fontFamily: 'Montserrat Bold',
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    ),
  );
}
