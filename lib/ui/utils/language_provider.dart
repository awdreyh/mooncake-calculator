import 'package:flutter/material.dart';

class LanguageProvider extends ChangeNotifier {
  String _languageCode = 'zh';

  String get languageCode => _languageCode;

  Locale get locale => Locale(_languageCode);

  void setLanguage(String code) {
    if (_languageCode != code) {
      _languageCode = code;
      notifyListeners();
    }
  }

  void toggleLanguage() {
    _languageCode = _languageCode == 'zh' ? 'en' : 'zh';
    notifyListeners();
  }
}
