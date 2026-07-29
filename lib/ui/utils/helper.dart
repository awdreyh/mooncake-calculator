import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_strings.dart';
import 'language_provider.dart';

class Helper {
  static String greeting(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final lang = languageProvider.languageCode;
    final hour = DateTime.now().hour;

    if (hour < 12) return AppStrings.get('goodMorning', lang);
    if (hour < 17) return AppStrings.get('goodAfternoon', lang);
    return AppStrings.get('goodEvening', lang);
  }

  static String ratioToString(double ratio) {
    final clampedRatio = ratio.clamp(0.0, 1.0);
    final firstPart = (clampedRatio * 10).round().toInt();
    final secondPart = 10 - firstPart;

    return '$firstPart:$secondPart';
  }

  static double stringToRatio(String value) {
    if (value.isEmpty) return 0.0;

    final parts = value.split(':');
    if (parts.length != 2) return 0.0;

    final firstPart = int.tryParse(parts[0].trim()) ?? 0;
    final secondPart = int.tryParse(parts[1].trim()) ?? 0;

    final total = firstPart + secondPart;
    if (total <= 0) return 0.0;

    return (firstPart / total).clamp(0.0, 1.0);
  }
}

