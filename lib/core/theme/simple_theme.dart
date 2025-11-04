import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SimpleTheme {
  // Colors
  static const Color pigeonBlue = Color(0xFF1a56db);
  static const Color pigeonPurple = Color(0xFF7c3aed);
  static const Color pigeonAccent = Color(0xFF60a5fa);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamilyFallback: const [
        'Noto Sans',
        'Noto Sans Symbols 2',
        'Noto Color Emoji',
        'Apple Color Emoji',
        'Segoe UI Emoji',
      ],
      colorScheme: ColorScheme.fromSeed(
        seedColor: pigeonBlue,
        brightness: Brightness.light,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey.shade100,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamilyFallback: const [
        'Noto Sans',
        'Noto Sans Symbols 2',
        'Noto Color Emoji',
        'Apple Color Emoji',
        'Segoe UI Emoji',
      ],
      colorScheme: ColorScheme.fromSeed(
        seedColor: pigeonBlue,
        brightness: Brightness.dark,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey.shade800,
      ),
    );
  }
}
