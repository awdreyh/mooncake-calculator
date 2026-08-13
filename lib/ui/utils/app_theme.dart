import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const double buttonRadius = 6.0;
  static final BorderRadius globalRadius = BorderRadius.circular(buttonRadius);

  static final ColorScheme colorScheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFFB7833A),
  );

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: const Color(0xFFF4E7D8),   
    canvasColor: const Color(0xFFF8EFE5),
    textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme).copyWith(
      headlineLarge: GoogleFonts.inter(
        fontWeight: FontWeight.w900,
        fontSize: 40,
        color: const Color(0xFF2C1A03),
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 18,
        color: const Color(0xFF2C1A03),
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 16,
        color: Colors.black87,
      ),
      titleLarge: GoogleFonts.inter(
        fontWeight: FontWeight.w700,
        fontSize: 20,
        color: const Color(0xFF2C1A03),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        shape: RoundedRectangleBorder(
          borderRadius: globalRadius,
        ),
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: globalRadius,
        ),
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        shape: RoundedRectangleBorder(
          borderRadius: globalRadius,
        ),
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
      ),
    ),
    cardTheme: CardThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: globalRadius,
      ),
    ),
  );
}