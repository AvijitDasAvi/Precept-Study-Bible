import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_translations.dart';
import 'package:flutter_localization/flutter_localization.dart';

class LocaleNotifier extends ValueNotifier<Locale> {
  LocaleNotifier(super.value);
}

class LocalizationService {
  static final fallbackLocale = Locale('en', 'US');

  static final supportedLocales = [Locale('en', 'US'), Locale('es', 'ES')];

  static const _prefsKey = 'selected_locale';

  static final LocaleNotifier localeNotifier = LocaleNotifier(fallbackLocale);

  static Future<Locale> deviceLocaleAsync() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefsKey);
    if (saved != null && saved.isNotEmpty) {
      final parts = saved.split('_');
      if (parts.length == 2) return Locale(parts[0], parts[1]);
    }

    final locale = Get.deviceLocale;
    if (locale == null) return fallbackLocale;
    final supported = supportedLocales.firstWhere(
      (l) => l.languageCode == locale.languageCode,
      orElse: () => fallbackLocale,
    );
    return supported;
  }

  static Locale get deviceLocale => fallbackLocale;

  static String translate(String key) {
    try {
      final flutterLocalization = FlutterLocalization.instance;
      final locale = flutterLocalization.currentLocale ?? fallbackLocale;
      final mapKey = '${locale.languageCode}_${locale.countryCode ?? ''}'
          .replaceAll('__', '_')
          .trim();
      if (AppTranslations.translations.containsKey(mapKey)) {
        final m = AppTranslations.translations[mapKey]!;
        return m[key] ?? key;
      }
      final langOnly = locale.languageCode;
      final found = AppTranslations.translations.entries.firstWhere(
        (e) => e.key.startsWith(langOnly),
        orElse: () => MapEntry('en_US', AppTranslations.translations['en_US']!),
      );
      return found.value[key] ?? key;
    } catch (e) {
      return key;
    }
  }

  static void changeLocale(Locale locale) {
    final flutterLocalization = FlutterLocalization.instance;
    flutterLocalization.translate(locale.languageCode);
    localeNotifier.value = locale;
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString(
        _prefsKey,
        '${locale.languageCode}_${locale.countryCode}',
      );
    });
  }

  static Future<void> init() async {
    final locale = await deviceLocaleAsync();
    final flutterLocalization = FlutterLocalization.instance;
    final mapLocales = <MapLocale>[];
    AppTranslations.translations.forEach((key, map) {
      final parts = key.split('_');
      if (parts.length == 2) {
        mapLocales.add(MapLocale(parts[0], map));
      }
    });

    flutterLocalization.init(
      mapLocales: mapLocales,
      initLanguageCode: locale.languageCode,
    );

    localeNotifier.value = locale;
  }
}
