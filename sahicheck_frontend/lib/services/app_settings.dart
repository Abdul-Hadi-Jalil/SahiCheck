import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Stores app-wide settings such as locale (English / Urdu).
class AppSettings extends ChangeNotifier {
  AppSettings._();
  static final AppSettings instance = AppSettings._();

  static const _localeKey = 'app_locale';

  Locale _locale = const Locale('en');
  Locale get locale => _locale;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_localeKey);
    if (code == 'ur') {
      _locale = const Locale('ur');
    } else {
      _locale = const Locale('en');
    }
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
  }

  Future<void> toggleUrdu(bool useUrdu) async {
    await setLocale(useUrdu ? const Locale('ur') : const Locale('en'));
  }
}
