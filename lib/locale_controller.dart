import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleController extends ChangeNotifier {
  LocaleController() : _locale = const Locale('fr');

  Locale _locale;
  Locale get locale => _locale;

  Future<void> charger() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('langue') ?? 'fr';
    _locale = _normaliserLocale(code);
    notifyListeners();
  }

  Future<void> changer(String code) async {
    final newLocale = _normaliserLocale(code);
    if (newLocale.languageCode == _locale.languageCode) {
      return;
    }
    _locale = newLocale;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('langue', newLocale.languageCode);
  }

  Locale _normaliserLocale(String code) {
    switch (code.toLowerCase()) {
      case 'ar':
        return const Locale('ar');
      case 'fr':
      default:
        return const Locale('fr');
    }
  }
}

final appLocaleController = LocaleController();
