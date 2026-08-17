import 'package:flutter/material.dart';
import '../models/settings_model.dart';
import '../services/database_service.dart';
import '../utils/constants.dart';

/// SettingsProvider — manages AppSettings state (language, theme, setup wizard).
class SettingsProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService.instance;

  AppSettings get settings {
    var s = _db.settings.get(AppConstants.settingsKey);
    if (s == null) {
      s = AppSettings();
      _db.settings.put(AppConstants.settingsKey, s);
    }
    return s;
  }

  bool get isSetupComplete => settings.setupComplete;
  bool get isDarkMode => settings.darkMode;
  String get language => settings.language;
  bool get isTamil => language == 'ta';

  ThemeMode get themeMode => isDarkMode ? ThemeMode.dark : ThemeMode.light;

  Future<void> completeSetup({
    required String userName,
    required String accountName,
    required double openingBalance,
  }) async {
    final s = settings;
    s.userName = userName;
    s.accountName = accountName;
    s.openingBalance = openingBalance;
    s.setupComplete = true;
    await s.save();
    notifyListeners();
  }

  Future<void> updateProfile({String? userName, String? accountName, double? openingBalance}) async {
    final s = settings;
    if (userName != null) s.userName = userName;
    if (accountName != null) s.accountName = accountName;
    if (openingBalance != null) s.openingBalance = openingBalance;
    await s.save();
    notifyListeners();
  }

  Future<void> toggleDarkMode(bool value) async {
    final s = settings;
    s.darkMode = value;
    await s.save();
    notifyListeners();
  }

  Future<void> setLanguage(String lang) async {
    final s = settings;
    s.language = lang;
    await s.save();
    notifyListeners();
  }

  Future<void> setPinEnabled(bool value) async {
    final s = settings;
    s.pinEnabled = value;
    await s.save();
    notifyListeners();
  }

  Future<void> setBiometricEnabled(bool value) async {
    final s = settings;
    s.biometricEnabled = value;
    await s.save();
    notifyListeners();
  }

  void refresh() => notifyListeners();
}
