import 'package:shared_preferences/shared_preferences.dart';

class LanguageService {
  static const String key = "isChinese";

  static Future<bool> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? false; // default: English
  }

  static Future<void> setLanguage(bool isChinese) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, isChinese);
  }
}
