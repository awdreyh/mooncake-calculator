import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // ============================================================
  // COLORS
  // ============================================================

  static const Color primary = Color(0xFF2563EB);
  static const Color primaryDark = Color(0xFF1D4ED8);
  static const Color primaryLight = Color(0xFF60A5FA);

  static const Color secondary = Color(0xFF7C3AED);
  static const Color secondaryDark = Color(0xFF6D28D9);
  static const Color secondaryLight = Color(0xFFA78BFA);

  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFDC2626);
  static const Color info = Color(0xFF0284C7);

  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Colors.white;

  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);

  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF64748B);

  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);

  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderDark = Color(0xFF334155);

    static const Color darkBrown = Color(0xFF2A1D18);
  static const Color ivory = Color(0xFFFAF8F3);

  static const Color terracotta = Color(0xFFC96B35);
  static const Color terracottaLight = Color(0xFFE3A078);

  static const Color textMuted = Color(0xFF776B61);

  static const Color espresso = Color(0xFF1C1411);
  static const Color cream = Color(0xFFF5F1E9);

  static const Color textDark = Color(0xFF241A16);
  static const Color textLight = Color(0xFFF8F4EC);
  static const Color textLightMuted = Color(0xFFC8BFB5);

  static const Color border = Color(0xFFD7CFC2);
  static const Color darkBorder = Color(0xFF493A31);



  // ============================================================
  // DIMENSIONS
  // ============================================================

  static const double radiusSmall = 6;
  static const double radiusMedium = 10;
  static const double radiusLarge = 16;
  static const double radiusXLarge = 24;

  static const double buttonHeight = 48;
  static const double inputHeight = 52;

  // ============================================================
  // LIGHT THEME
  // ============================================================

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: primary,
      onPrimary: Colors.white,
      secondary: secondary,
      onSecondary: Colors.white,
      error: error,
      surface: surfaceLight,
    );

    return ThemeData(
      useMaterial3: true,

      // ----------------------------------------------------------
      // COLOR
      // ----------------------------------------------------------

      colorScheme: colorScheme,

      scaffoldBackgroundColor: backgroundLight,

      // ----------------------------------------------------------
      // TYPOGRAPHY
      // ----------------------------------------------------------

      fontFamily: 'Inter',

      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w700,
          height: 1.2,
          color: textPrimaryLight,
        ),
        displayMedium: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          height: 1.2,
          color: textPrimaryLight,
        ),
        displaySmall: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          height: 1.25,
          color: textPrimaryLight,
        ),

        headlineLarge: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w700,
          height: 1.25,
          color: textPrimaryLight,
        ),
        headlineMedium: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          height: 1.3,
          color: textPrimaryLight,
        ),
        headlineSmall: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          height: 1.3,
          color: textPrimaryLight,
        ),

        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          height: 1.35,
          color: textPrimaryLight,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          height: 1.4,
          color: textPrimaryLight,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          height: 1.4,
          color: textPrimaryLight,
        ),

        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 1.5,
          color: textPrimaryLight,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.5,
          color: textPrimaryLight,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          height: 1.4,
          color: textSecondaryLight,
        ),

        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textPrimaryLight,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textPrimaryLight,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: textSecondaryLight,
        ),
      ),

      // ----------------------------------------------------------
      // APP BAR
      // ----------------------------------------------------------

      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceLight,
        foregroundColor: textPrimaryLight,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 1,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimaryLight,
        ),
      ),

      // ----------------------------------------------------------
      // CARD
      // ----------------------------------------------------------

      cardTheme: CardThemeData(
        color: surfaceLight,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          side: const BorderSide(
            color: borderLight,
          ),
        ),
      ),

      // ----------------------------------------------------------
      // ELEVATED BUTTON
      // ----------------------------------------------------------

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(0, buttonHeight),
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ----------------------------------------------------------
      // OUTLINED BUTTON
      // ----------------------------------------------------------

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, buttonHeight),
          foregroundColor: primary,
          side: const BorderSide(
            color: primary,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ----------------------------------------------------------
      // TEXT BUTTON
      // ----------------------------------------------------------

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          minimumSize: const Size(0, buttonHeight),
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ----------------------------------------------------------
      // INPUT FIELDS
      // ----------------------------------------------------------

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceLight,

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),

        hintStyle: const TextStyle(
          color: textSecondaryLight,
          fontSize: 14,
        ),

        labelStyle: const TextStyle(
          color: textSecondaryLight,
          fontSize: 14,
        ),

        floatingLabelStyle: const TextStyle(
          color: primary,
          fontWeight: FontWeight.w500,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(
            color: borderLight,
          ),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(
            color: borderLight,
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(
            color: primary,
            width: 2,
          ),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(
            color: error,
          ),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(
            color: error,
            width: 2,
          ),
        ),

        errorStyle: const TextStyle(
          color: error,
          fontSize: 12,
        ),
      ),

      // ----------------------------------------------------------
      // CHECKBOX
      // ----------------------------------------------------------

      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        side: const BorderSide(
          color: borderLight,
          width: 1.5,
        ),
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primary;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
      ),

      // ----------------------------------------------------------
      // RADIO
      // ----------------------------------------------------------

      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primary;
          }
          return textSecondaryLight;
        }),
      ),

      // ----------------------------------------------------------
      // SWITCH
      // ----------------------------------------------------------

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return textSecondaryLight;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primary;
          }
          return borderLight;
        }),
      ),

      // ----------------------------------------------------------
      // DIVIDER
      // ----------------------------------------------------------

      dividerTheme: const DividerThemeData(
        color: borderLight,
        thickness: 1,
        space: 1,
      ),

      // ----------------------------------------------------------
      // BOTTOM NAVIGATION
      // ----------------------------------------------------------

      navigationBarTheme: NavigationBarThemeData(
  backgroundColor: ivory,
  surfaceTintColor: Colors.transparent,
  elevation: 0,

  indicatorColor: terracotta.withValues(alpha: 0.12),

  iconTheme: WidgetStateProperty.resolveWith<IconThemeData>(
    (states) {
      if (states.contains(WidgetState.selected)) {
        return const IconThemeData(
          color: terracotta,
          size: 21,
        );
      }

      return const IconThemeData(
        color: textMuted,
        size: 20,
      );
    },
  ),

  labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
    (states) {
      if (states.contains(WidgetState.selected)) {
        return GoogleFonts.inter(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: terracotta,
        );
      }

      return GoogleFonts.inter(
        fontSize: 9,
        fontWeight: FontWeight.w400,
        color: textMuted,
      );
    },
  ),
),

      // ----------------------------------------------------------
      // FLOATING ACTION BUTTON
      // ----------------------------------------------------------

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 2,
      ),

      // ----------------------------------------------------------
      // DIALOG
      // ----------------------------------------------------------

      dialogTheme: DialogThemeData(
        backgroundColor: surfaceLight,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
        ),
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimaryLight,
        ),
        contentTextStyle: const TextStyle(
          fontSize: 14,
          height: 1.5,
          color: textSecondaryLight,
        ),
      ),

      // ----------------------------------------------------------
      // SNACKBAR
      // ----------------------------------------------------------

      snackBarTheme: SnackBarThemeData(
        backgroundColor: textPrimaryLight,
        contentTextStyle: const TextStyle(
          fontSize: 14,
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // ----------------------------------------------------------
      // PROGRESS INDICATOR
      // ----------------------------------------------------------

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primary,
      ),

      // ----------------------------------------------------------
      // ICONS
      // ----------------------------------------------------------

      iconTheme: const IconThemeData(
        color: textPrimaryLight,
        size: 24,
      ),
    );
  }

  // ============================================================
  // DARK THEME
  // ============================================================

  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.dark,
    ).copyWith(
      primary: primaryLight,
      onPrimary: Colors.white,
      secondary: secondaryLight,
      onSecondary: Colors.white,
      error: Color(0xFFF87171),
      surface: surfaceDark,
    );

    return ThemeData(
      useMaterial3: true,

      colorScheme: colorScheme,

      scaffoldBackgroundColor: backgroundDark,

      fontFamily: 'Inter',

      // ----------------------------------------------------------
      // TYPOGRAPHY
      // ----------------------------------------------------------

      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w700,
          height: 1.2,
          color: textPrimaryDark,
        ),
        displayMedium: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          height: 1.2,
          color: textPrimaryDark,
        ),
        displaySmall: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          height: 1.25,
          color: textPrimaryDark,
        ),

        headlineLarge: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w700,
          color: textPrimaryDark,
        ),
        headlineMedium: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: textPrimaryDark,
        ),
        headlineSmall: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimaryDark,
        ),

        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimaryDark,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textPrimaryDark,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textPrimaryDark,
        ),

        bodyLarge: TextStyle(
          fontSize: 16,
          height: 1.5,
          color: textPrimaryDark,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          height: 1.5,
          color: textPrimaryDark,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: textSecondaryDark,
        ),

        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textPrimaryDark,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textPrimaryDark,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          color: textSecondaryDark,
        ),
      ),

      // ----------------------------------------------------------
      // APP BAR
      // ----------------------------------------------------------

      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceDark,
        foregroundColor: textPrimaryDark,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimaryDark,
        ),
      ),

      // ----------------------------------------------------------
      // CARD
      // ----------------------------------------------------------

      cardTheme: CardThemeData(
        color: surfaceDark,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          side: const BorderSide(
            color: borderDark,
          ),
        ),
      ),

      // ----------------------------------------------------------
      // BUTTONS
      // ----------------------------------------------------------

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(0, buttonHeight),
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, buttonHeight),
          foregroundColor: primaryLight,
          side: const BorderSide(
            color: primaryLight,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryLight,
          minimumSize: const Size(0, buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
        ),
      ),

      // ----------------------------------------------------------
      // INPUT
      // ----------------------------------------------------------

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceDark,

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),

        hintStyle: const TextStyle(
          color: textSecondaryDark,
          fontSize: 14,
        ),

        labelStyle: const TextStyle(
          color: textSecondaryDark,
          fontSize: 14,
        ),

        floatingLabelStyle: const TextStyle(
          color: primaryLight,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(
            color: borderDark,
          ),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(
            color: borderDark,
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(
            color: primaryLight,
            width: 2,
          ),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(
            color: error,
          ),
        ),
      ),

      // ----------------------------------------------------------
      // DIVIDER
      // ----------------------------------------------------------

      dividerTheme: const DividerThemeData(
        color: borderDark,
        thickness: 1,
        space: 1,
      ),

      // ----------------------------------------------------------
      // NAVIGATION
      // ----------------------------------------------------------

     navigationBarTheme: NavigationBarThemeData(
  backgroundColor: darkBrown,
  surfaceTintColor: Colors.transparent,
  elevation: 0,

  indicatorColor: terracotta.withValues(alpha: 0.2),

  iconTheme: WidgetStateProperty.resolveWith<IconThemeData>(
    (states) {
      if (states.contains(WidgetState.selected)) {
        return const IconThemeData(
          color: terracottaLight,
          size: 21,
        );
      }

      return const IconThemeData(
        color: textLightMuted,
        size: 20,
      );
    },
  ),

  labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
    (states) {
      if (states.contains(WidgetState.selected)) {
        return GoogleFonts.inter(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: terracottaLight,
        );
      }

      return GoogleFonts.inter(
        fontSize: 9,
        fontWeight: FontWeight.w400,
        color: textLightMuted,
      );
    },
  ),
),
      // ----------------------------------------------------------
      // FAB
      // ----------------------------------------------------------

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),

      // ----------------------------------------------------------
      // DIALOG
      // ----------------------------------------------------------

      dialogTheme: DialogThemeData(
        backgroundColor: surfaceDark,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
        ),
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimaryDark,
        ),
        contentTextStyle: const TextStyle(
          fontSize: 14,
          height: 1.5,
          color: textSecondaryDark,
        ),
      ),

      // ----------------------------------------------------------
      // SNACKBAR
      // ----------------------------------------------------------

      snackBarTheme: SnackBarThemeData(
        backgroundColor: Colors.white,
        contentTextStyle: const TextStyle(
          fontSize: 14,
          color: textPrimaryLight,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryLight,
      ),

      iconTheme: const IconThemeData(
        color: textPrimaryDark,
        size: 24,
      ),
    );
  }
}