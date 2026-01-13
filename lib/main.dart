import 'package:calvinlockhart/app.dart';
import 'package:flutter/material.dart';
import 'package:calvinlockhart/core/utils/localization/localization_service.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterLocalization.instance.ensureInitialized();
  await LocalizationService.init();

  bool isLoggedIn = false;
  bool isOfflineMode = false;

  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token') ?? '';
    isLoggedIn = token.isNotEmpty;

    // In offline mode, user will be taken directly to Downloads screen
    // Offline mode is triggered when user has a token but no internet connection
    // The network layer will handle offline detection and can trigger navigation
  } catch (_) {}

  runApp(CalvinLockHart(isLoggedIn: isLoggedIn, isOfflineMode: isOfflineMode));
}
