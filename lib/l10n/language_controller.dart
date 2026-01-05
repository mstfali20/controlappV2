import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider with ChangeNotifier {
  late SharedPreferences _prefs;
  String? _locale;
  String get locale => _locale ?? "en"; // Null kontrolü yapıldı

  bool _isLanguageOptionsVisible =
      false; // Dil seçeneklerinin görünürlüğünü kontrol eden değişken
  bool get isLanguageOptionsVisible => _isLanguageOptionsVisible; // Getter

  LanguageProvider({required String savedLocale}) {
    _locale = savedLocale;
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    _prefs = await SharedPreferences.getInstance();
    _locale = _prefs.getString('locale') ?? _locale;
    notifyListeners();
  }

  Future<void> _saveLocale(String languageCode) async {
    _locale = languageCode;
    await _prefs.setString('locale', languageCode);
    notifyListeners();
  }

  Future<void> setLanguage(String languageCode) async {
    await _saveLocale(languageCode);
  }

  // Dil seçeneklerinin görünürlüğünü değiştirir
  void toggleLanguageOptionsVisibility() {
    _isLanguageOptionsVisible = !_isLanguageOptionsVisible;
    notifyListeners(); // Dinleyicilere görünürlük durumunun değiştiği bildiriliyor
  }
}
