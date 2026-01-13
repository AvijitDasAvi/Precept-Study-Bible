import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:calvinlockhart/core/utils/localization/localization_service.dart';

class SettingsController extends GetxController {
  var themeMode = ThemeMode.light.obs;
  var selectedLanguage = 'English'.obs;

  @override
  void onInit() {
    super.onInit();
    _loadThemePreference();
    _loadLanguagePreference();
  }

  Future<void> _loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getString('theme_mode') ?? 'light';
      themeMode.value = savedTheme == 'dark' ? ThemeMode.dark : ThemeMode.light;
    } catch (e) {
      debugPrint('Error loading theme preference: $e');
    }
  }

  Future<void> _loadLanguagePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString('selected_language');
      if (saved != null && saved.isNotEmpty) {
        selectedLanguage.value = saved;
      } else {
        final locale = Get.locale ?? LocalizationService.deviceLocale;
        if (locale.languageCode == 'es') {
          selectedLanguage.value = 'Spanish';
        } else {
          selectedLanguage.value = 'English';
        }
      }
    } catch (e) {
      debugPrint('Error loading language preference: $e');
    }
  }

  Future<void> toggleThemeMode(bool isDarkMode) async {
    try {
      themeMode.value = isDarkMode ? ThemeMode.dark : ThemeMode.light;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('theme_mode', isDarkMode ? 'dark' : 'light');
      Get.changeThemeMode(themeMode.value);
    } catch (e) {
      debugPrint('Error toggling theme mode: $e');
    }
  }

  void changeLanguage(String value) {
    selectedLanguage.value = value;
    if (value == 'Spanish') {
      LocalizationService.changeLocale(Locale('es', 'ES'));
    } else {
      LocalizationService.changeLocale(Locale('en', 'US'));
    }
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('selected_language', value);
    });
  }
}
