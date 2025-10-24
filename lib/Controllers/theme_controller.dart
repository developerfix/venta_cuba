import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends GetxController {
  static const String _themeKey = 'isDarkMode';

  // Observable for dark mode state
  RxBool isDarkMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadThemeFromPrefs();
  }

  // Load theme preference from SharedPreferences
  Future<void> loadThemeFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      isDarkMode.value = prefs.getBool(_themeKey) ?? false;
      updateSystemUIOverlay();
      update(); // Notify GetBuilder
    } catch (e) {}
  }

  // Save theme preference to SharedPreferences
  Future<void> _saveThemeToPrefs(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themeKey, value);
    } catch (e) {}
  }

  // Toggle between light and dark mode
  Future<void> toggleTheme() async {
    isDarkMode.value = !isDarkMode.value;
    await _saveThemeToPrefs(isDarkMode.value);
    updateSystemUIOverlay();
  }

  // Update system UI overlay style based on current theme
  void updateSystemUIOverlay() {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            isDarkMode.value ? Brightness.light : Brightness.dark,
        statusBarBrightness:
            isDarkMode.value ? Brightness.dark : Brightness.light,
        systemNavigationBarColor:
            isDarkMode.value ? const Color(0xFF121212) : Colors.white,
        systemNavigationBarIconBrightness:
            isDarkMode.value ? Brightness.light : Brightness.dark,
      ),
    );
  }

  // Get current theme mode
  ThemeMode get themeMode =>
      isDarkMode.value ? ThemeMode.dark : ThemeMode.light;

  // Check if current theme is dark
  bool get isCurrentThemeDark => isDarkMode.value;
}
