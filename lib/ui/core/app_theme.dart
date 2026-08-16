import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// -----------------------------------------------------------------------
/// APP THEME — "Table" (inspired by the warm, editorial food/restaurant UI)
/// -----------------------------------------------------------------------
/// Palette:
///  - Deep espresso brown for headers/footers & primary text
///  - Warm cream/off-white for main backgrounds
///  - Burnt orange as the single accent color
///  - Serif italic display font for headlines, clean sans for body/UI
/// -----------------------------------------------------------------------

class AppColors {
  AppColors._();

  // Core palette
  static const Color espresso = Color(
    0xFF241812,
  ); // near-black brown (hero/footer bg)
  static const Color espressoLight = Color(
    0xFF3A2A21,
  ); // secondary dark surface
  static const Color cream = Color(0xFFFAF7F2); // main app background
  static const Color creamAlt = Color(0xFFF3ECE0); // secondary panel bg
  static const Color cardBg = Color(0xFFFDFCF8);
  static const Color accent = Color(0xFFD6803F,); // burnt orange (buttons, price, tags)
  static const Color accentDark = Color(0xFFC4622D);
  static const Color accentLight = Color(0xFFF5F1E8);
  static const Color borderLight = Color(0xFFC3BDB1);
  static const Color sectionBg = Color(0xFFF5F1E8);

  static const Color textPrimary = Color(0xFF1C1410); // on cream
  static const Color textSecondary = Color(0xFF7A6E62);
  static const Color textOnDark = Color(0xFFF6EFE4);
  static const Color textOnDarkMuted = Color(0xFFC9BBAA);

  static const Color divider = Color(0xFFE7DFD2);
  static const Color star = Color(0xFFD6803F);
  static const Color chipBg = Color(0xFFF1EAE0);
  static const Color chipBorder = Color(0xFFE1D7C7);

  static const Color statusOpen = Color(0xFF5C8A5C);
  static const Color statusClosed = Color(0xFF8A5C5C);
}

class AppTheme {
  AppTheme._();

  static const double buttonRadius = 6.0;
  static final BorderRadius globalRadius = BorderRadius.circular(buttonRadius);

  // Serif italic display face — used for hero headlines & section titles
  static TextStyle _display(
    double size,
    FontWeight weight,
    Color color, {
    bool italic = false,
  }) => GoogleFonts.playfairDisplay(
    fontSize: size,
    fontWeight: weight,
    fontStyle: italic ? FontStyle.italic : FontStyle.normal,
    color: color,
    height: 1.15,
  );

  // Clean sans — body copy, labels, buttons
  static TextStyle _body(
    double size,
    FontWeight weight,
    Color color, {
    double? letterSpacing,
  }) => GoogleFonts.inter(
    fontSize: size,
    fontWeight: weight,
    color: color,
    letterSpacing: letterSpacing,
    height: 1.4,
  );

  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);

    final textTheme = base.textTheme.copyWith(
      // Hero / big italic headline e.g. "Eat with intention."
      displayLarge: _display(
        44,
        FontWeight.w600,
        AppColors.textOnDark,
        italic: true,
      ),
      displayMedium: _display(34, FontWeight.w600, AppColors.textPrimary),
      // Section titles e.g. "Tonight's featured plates"
      headlineLarge: _display(30, FontWeight.w700, AppColors.textPrimary),
      headlineMedium: _display(
        24,
        FontWeight.w600,
        AppColors.textPrimary,
        italic: true,
      ),
      // Card titles e.g. "Seared Duck Confit"
      titleLarge: _body(18, FontWeight.w700, AppColors.textPrimary),
      titleMedium: _body(15, FontWeight.w600, AppColors.textPrimary),
      // Body copy
      bodyLarge: _body(15, FontWeight.w400, AppColors.textPrimary),
      bodyMedium: _body(13.5, FontWeight.w400, AppColors.textSecondary),
      bodySmall: _body(12, FontWeight.w400, AppColors.textSecondary),
      // Overline / eyebrow labels e.g. "ON THE MENU"
      labelLarge: _body(
        12,
        FontWeight.w600,
        AppColors.textPrimary,
        letterSpacing: 1.6,
      ),
      labelMedium: _body(
        11,
        FontWeight.w600,
        AppColors.textSecondary,
        letterSpacing: 1.2,
      ),
      labelSmall: _body(
        10,
        FontWeight.w500,
        AppColors.textSecondary,
        letterSpacing: 1.0,
      ),
    );

    return base.copyWith(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.cream,
      primaryColor: AppColors.espressoLight,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.textSecondary,
        onPrimary: Colors.white,
        secondary: AppColors.espresso,
        onSecondary: AppColors.textOnDark,
        surface: AppColors.cardBg,
        onSurface: AppColors.textPrimary,
        error: const Color(0xFFB3412C),
        outline: AppColors.borderLight,
      ),
      textTheme: textTheme,

      // ---- AppBar: minimal, cream, dark wordmark ----
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.cream,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: _display(20, FontWeight.w700, AppColors.textPrimary),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),

      // ---- Buttons ----
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.cream,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          textStyle: _body(
            13,
            FontWeight.w600,
            Colors.white,
            letterSpacing: 0.6,
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textSecondary,
          backgroundColor: Colors.white,
          side: const BorderSide(color: AppColors.textOnDarkMuted, width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          textStyle: _body(
            13,
            FontWeight.w600,
            AppColors.textOnDark,
            letterSpacing: 0.6,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.accentLight,
          foregroundColor: AppColors.textPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          textStyle: _body(
            13,
            FontWeight.w600,
            AppColors.textPrimary,
            letterSpacing: 0.6,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          textStyle: _body(13, FontWeight.w600, AppColors.textPrimary),
        ),
      ),

      // ---- Cards: dish/restaurant cards, soft shadow, rounded ----
      cardTheme: CardThemeData(
        color: AppColors.cardBg,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.divider, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
      ),

      // ---- Chips: filter pills ("All", "Italian", "Japanese"...) ----
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.chipBg,
        selectedColor: AppColors.espresso,
        disabledColor: AppColors.chipBg,
        labelStyle: _body(12.5, FontWeight.w500, AppColors.textPrimary),
        secondaryLabelStyle: _body(12.5, FontWeight.w500, AppColors.textOnDark),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        shape: StadiumBorder(side: BorderSide(color: AppColors.chipBorder)),
        side: BorderSide(color: AppColors.chipBorder),
      ),

      // ---- Inputs: newsletter field, search etc. ----
      inputDecorationTheme: InputDecorationTheme(
        isDense: true,
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.06),       
        hintStyle: _body(13, FontWeight.w400, AppColors.textOnDarkMuted),
        
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(
            color: AppColors.textOnDarkMuted,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(
            color: AppColors.textOnDarkMuted,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(
            color: AppColors.textSecondary,
            width: 1.4,
          ),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),

      iconTheme: const IconThemeData(color: AppColors.textPrimary),

      splashColor: AppColors.accent.withValues(alpha: 0.08),
      highlightColor: Colors.transparent,
    );
  }
}

/// Reusable rating-star row (used across dish/restaurant cards).
class RatingStars extends StatelessWidget {
  const RatingStars({
    super.key,
    required this.rating,
    this.count,
    this.size = 14,
  });

  final double rating; // 0..5
  final int? count;
  final double size;

  @override
  Widget build(BuildContext context) {
    final full = rating.floor();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < 5; i++)
          Icon(
            i < full ? Icons.star_rounded : Icons.star_border_rounded,
            size: size,
            color: AppColors.star,
          ),
        const SizedBox(width: 6),
        Text(
          count != null ? '$rating ($count)' : '$rating',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

/// Small rounded status/category badge (e.g. "OPEN", "FRENCH").
class TagBadge extends StatelessWidget {
  const TagBadge(this.label, {super.key, this.dark = true, this.color});

  final String label;
  final bool dark;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color ?? (dark ? AppColors.espresso : AppColors.chipBg),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
          color: dark ? AppColors.textOnDark : AppColors.textPrimary,
        ),
      ),
    );
  }
}
