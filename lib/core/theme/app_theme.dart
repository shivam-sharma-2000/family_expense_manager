import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {

  static TextTheme _buildTextTheme(Color bodyColor, Color displayColor) {
    return TextTheme(
      displayLarge: GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
        color: displayColor,
      ),
      displayMedium: GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
        color: displayColor,
      ),
      displaySmall: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: displayColor,
      ),
      bodyLarge: GoogleFonts.poppins(
        fontSize: 16,
        height: 1.5,
        color: bodyColor,
      ),
      bodyMedium: GoogleFonts.poppins(
        fontSize: 14,
        height: 1.5,
        color: bodyColor,
      ),
      bodySmall: GoogleFonts.poppins(
        fontSize: 12,
        height: 1.5,
        color: bodyColor,
      ),
      labelLarge: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: Colors.white, // Standard button text color
      ),
      titleMedium: GoogleFonts.poppins(
        color: displayColor, // Text field input color
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primarySwatch: Colors.indigo,
      primaryColor: const Color(0xFF6C63FF),
      scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
        titleTextStyle: GoogleFonts.poppins(
          color: const Color(0xFF1E293B),
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
      textTheme: _buildTextTheme(const Color(0xFF64748B), const Color(0xFF1E293B)),
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
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: GoogleFonts.poppins(
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
      textTheme: _buildTextTheme(const Color(0xFFCBD5E1), Colors.white),
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
