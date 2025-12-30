import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  // --- KONFIGURASI DEFAULT (LEVEL 2) ---
  static const double defaultLevel = 2.0;

  ThemeMode _themeMode = ThemeMode.light;
  
  // Level saat ini (Default: 2.0)
  double _arabicLevel = defaultLevel;
  double _latinLevel = defaultLevel;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  // Getter Slider
  double get arabicLevel => _arabicLevel;
  double get latinLevel => _latinLevel;

  // --- RUMUS UKURAN FONT ---
  // Dengan Default Level 2:
  // Arab  = 16 + (2 * 4) = 24.0 px
  // Latin = 10 + (2 * 2) = 14.0 px
  
  double get arabicFontSize => 16.0 + (_arabicLevel * 4.0);
  double get latinFontSize => 10.0 + (_latinLevel * 2.0);

  SettingsProvider() {
    _loadSettings();
  }

  void toggleTheme(bool isDark) async {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark_mode', isDark);
  }

  void setArabicLevel(double level) async {
    _arabicLevel = level;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('arabic_level', level);
  }

  void setLatinLevel(double level) async {
    _latinLevel = level;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('latin_level', level);
  }

  // --- FUNGSI RESET ---
  void resetSettings() async {
    _arabicLevel = defaultLevel; // Reset ke 2.0
    _latinLevel = defaultLevel;  // Reset ke 2.0
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('arabic_level', defaultLevel);
    await prefs.setDouble('latin_level', defaultLevel);
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('is_dark_mode') ?? false;
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    
    // Jika belum ada data tersimpan, gunakan defaultLevel (2.0)
    _arabicLevel = prefs.getDouble('arabic_level') ?? defaultLevel;
    _latinLevel = prefs.getDouble('latin_level') ?? defaultLevel;
    
    notifyListeners();
  }
}