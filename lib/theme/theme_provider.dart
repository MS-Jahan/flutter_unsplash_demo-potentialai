import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themePreferenceKey = 'theme_preference';
  ThemeMode? _themeMode = ThemeMode.system;

  ThemeMode? get themeMode => _themeMode;

  ThemeProvider() {
    _loadThemePreference();
  }

  void toggleTheme(ThemeMode? themeMode) async {
    _themeMode = themeMode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themePreferenceKey, themeMode.toString().split('.').last);
  }

  void _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final themePreference = prefs.getString(_themePreferenceKey);
    if (themePreference != null) {
      _themeMode = ThemeMode.values.firstWhere((mode) => mode.toString().split('.').last == themePreference, orElse: () => ThemeMode.system);
    }
    notifyListeners();
  }
}
