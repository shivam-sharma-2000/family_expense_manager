import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LedgerlyColors {
  // Brand accents (same in light/dark)
  static const Color navy950 = Color(0xFF0B1220);
  static const Color navy900 = Color(0xFF10233B);
  static const Color gold = Color(0xFFC9972B);
  static const Color goldSoft = Color(0xFFF5E9CF);
  static const Color teal = Color(0xFF1F9D82);
  static const Color tealSoft = Color(0xFFDCF3EC);
  static const Color coral = Color(0xFFE4573D);
  static const Color coralSoft = Color(0xFFFBE2DC);
  static const Color amber = Color(0xFFE0A233);
  static const Color amberSoft = Color(0xFFFBEDD3);
  static const Color indigo = Color(0xFF3A4FBF);
  static const Color indigoSoft = Color(0xFFE4E7FB);

  // Light mode colors
  static const Color bgLight = Color(0xFFF5F6FA);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceAltLight = Color(0xFFEEF1F7);
  static const Color borderLight = Color(0xFFE1E5EF);
  static const Color inkLight = Color(0xFF1B2333);
  static const Color inkSoftLight = Color(0xFF5B6478);
  static const Color inkFaintLight = Color(0xFF8A93A6);

  // Dark mode colors
  static const Color bgDark = Color(0xFF0B111C);
  static const Color surfaceDark = Color(0xFF131B2B);
  static const Color surfaceAltDark = Color(0xFF1A2537);
  static const Color borderDark = Color(0xFF233046);
  static const Color inkDark = Color(0xFFE7ECF5);
  static const Color inkSoftDark = Color(0xFFA6B0C3);
  static const Color inkFaintDark = Color(0xFF6C7891);
}

class AppTheme {
  static TextTheme _buildTextTheme(Color inkColor, Color inkSoftColor, Color inkFaintColor) {
    return TextTheme(
      displayLarge: GoogleFonts.plusJakartaSans(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: inkColor,
      ),
      displayMedium: GoogleFonts.plusJakartaSans(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: inkColor,
      ),
      displaySmall: GoogleFonts.plusJakartaSans(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: inkColor,
      ),
      headlineLarge: GoogleFonts.plusJakartaSans(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: inkColor,
      ),
      headlineMedium: GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: inkColor,
      ),
      headlineSmall: GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: inkColor,
      ),
      titleLarge: GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: inkColor,
      ),
      titleMedium: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: inkColor,
      ),
      titleSmall: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: inkColor,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: inkColor,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: inkSoftColor,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: inkFaintColor,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: inkColor,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: inkSoftColor,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: inkFaintColor,
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: LedgerlyColors.gold,
      scaffoldBackgroundColor: LedgerlyColors.bgLight,
      cardColor: LedgerlyColors.surfaceLight,
      dividerColor: LedgerlyColors.borderLight,
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: LedgerlyColors.inkLight),
        titleTextStyle: GoogleFonts.plusJakartaSans(
          color: LedgerlyColors.navy900,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: LedgerlyColors.surfaceLight,
        selectedItemColor: LedgerlyColors.gold,
        unselectedItemColor: LedgerlyColors.inkSoftLight,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      textTheme: _buildTextTheme(
        LedgerlyColors.inkLight,
        LedgerlyColors.inkSoftLight,
        LedgerlyColors.inkFaintLight,
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: GoogleFonts.inter(color: LedgerlyColors.inkFaintLight),
        labelStyle: GoogleFonts.inter(color: LedgerlyColors.inkSoftLight),
        filled: true,
        fillColor: LedgerlyColors.surfaceLight,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: LedgerlyColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: LedgerlyColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: LedgerlyColors.gold, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: LedgerlyColors.coral),
        ),
      ),
      cardTheme: CardThemeData(
        color: LedgerlyColors.surfaceLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: LedgerlyColors.borderLight),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: LedgerlyColors.surfaceLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      colorScheme: const ColorScheme.light(
        primary: LedgerlyColors.gold,
        secondary: LedgerlyColors.navy900,
        surface: LedgerlyColors.surfaceLight,
        error: LedgerlyColors.coral,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: LedgerlyColors.inkLight,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: LedgerlyColors.gold,
      scaffoldBackgroundColor: LedgerlyColors.bgDark,
      cardColor: LedgerlyColors.surfaceDark,
      dividerColor: LedgerlyColors.borderDark,
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: LedgerlyColors.inkDark),
        titleTextStyle: GoogleFonts.plusJakartaSans(
          color: LedgerlyColors.inkDark,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: LedgerlyColors.surfaceDark,
        selectedItemColor: LedgerlyColors.gold,
        unselectedItemColor: LedgerlyColors.inkSoftDark,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      textTheme: _buildTextTheme(
        LedgerlyColors.inkDark,
        LedgerlyColors.inkSoftDark,
        LedgerlyColors.inkFaintDark,
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: GoogleFonts.inter(color: LedgerlyColors.inkFaintDark),
        labelStyle: GoogleFonts.inter(color: LedgerlyColors.inkSoftDark),
        filled: true,
        fillColor: LedgerlyColors.surfaceAltDark,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: LedgerlyColors.borderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: LedgerlyColors.borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: LedgerlyColors.gold, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: LedgerlyColors.coral),
        ),
      ),
      cardTheme: CardThemeData(
        color: LedgerlyColors.surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: LedgerlyColors.borderDark),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: LedgerlyColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      colorScheme: const ColorScheme.dark(
        primary: LedgerlyColors.gold,
        secondary: LedgerlyColors.navy900,
        surface: LedgerlyColors.surfaceDark,
        error: LedgerlyColors.coral,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: LedgerlyColors.inkDark,
      ),
    );
  }
}

