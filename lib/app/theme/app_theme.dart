import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primarySwatch: Colors.indigo,
      primaryColor: const Color(0xFF6C63FF),
      scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Color(0xFF1E293B)),
        titleTextStyle: TextStyle(
          color: Color(0xFF1E293B),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: Color(0xFF6C63FF),
        unselectedItemColor: Color(0xFF94A3B8),
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 10,
      ),
      cardColor: Colors.white,
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Color(0xFF1E293B)),
        bodyMedium: TextStyle(color: Color(0xFF64748B)),
        titleMedium: TextStyle(
          color: Color(0xFF1E293B),
        ), // Text field input color
      ),
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(color: Color(0xFF94A3B8)),
        labelStyle: TextStyle(color: Color(0xFF64748B)),
      ),
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF6C63FF),
        secondary: Color(0xFF10B981),
        error: Color(0xFFEF4444),
        surface: Colors.white,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primarySwatch: Colors.indigo,
      primaryColor: const Color(0xFF6C63FF),
      scaffoldBackgroundColor: const Color(0xFF0F172A),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1E293B),
        selectedItemColor: Color(0xFF818CF8),
        unselectedItemColor: Color(0xFF94A3B8),
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 10,
      ),
      cardColor: const Color(0xFF1E293B),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.white),
        bodyMedium: TextStyle(color: Color(0xFFCBD5E1)),
        titleMedium: TextStyle(color: Colors.white), // Text field input color
      ),
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(color: Color(0xFF94A3B8)),
        labelStyle: TextStyle(color: Color(0xFFCBD5E1)),
      ),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF818CF8),
        secondary: Color(0xFF34D399),
        error: Color(0xFFF87171),
        surface: Color(0xFF1E293B),
      ),
    );
  }
}
