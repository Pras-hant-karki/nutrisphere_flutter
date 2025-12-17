import 'package:flutter/material.dart';

ThemeData getApplicationTheme() {
  return ThemeData(
    useMaterial3: true,
    fontFamily: "OpenSans Regular",

    // color scheme
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color.fromARGB(255, 248, 248, 249),
    ),

    // app bar theme
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.lightBlueAccent,
      elevation: 2,
      centerTitle: true, // Center the title
      iconTheme: IconThemeData(color: Colors.black),
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold, // Bold
        color: Colors.black,
        fontFamily: "Montserrat Bold", // Montserrat Bold
      ),
    ),

    // text field theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      hintStyle: const TextStyle(
        fontSize: 14,
        color: Colors.black54,
      ),
      labelStyle: const TextStyle(
        fontSize: 15,
        color: Colors.deepPurple,
        fontWeight: FontWeight.w600,
      ),
    ),

    // text theme
    textTheme: const TextTheme(
    bodyMedium: TextStyle(
      fontSize: 14,
      fontFamily: 'OpenSans Regular',
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontFamily: 'OpenSans Regular',
    ),
    titleLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      fontFamily: 'Montserrat Bold',
    ),
  ),


    // bottom navigation theme
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color.fromARGB(255, 86, 6, 6),
      selectedItemColor: Colors.deepPurple,
      unselectedItemColor: Colors.black54,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      elevation: 10,
    ),

    // elevated button
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFDFF300),
        textStyle: const TextStyle(
          fontSize: 18,
          color: Colors.black12,
          fontWeight: FontWeight.bold,
          fontFamily: 'Montserrat Bold', // Use Bold here too
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    ),
  );
}
