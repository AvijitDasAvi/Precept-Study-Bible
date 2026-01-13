import 'package:calvinlockhart/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/bindings/controller_binder.dart';
import 'core/utils/theme/theme.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class CalvinLockHart extends StatefulWidget {
  final bool isLoggedIn;
  final bool isOfflineMode;

  const CalvinLockHart({
    super.key,
    this.isLoggedIn = false,
    this.isOfflineMode = false,
  });

  @override
  State<CalvinLockHart> createState() => _CalvinLockHartState();
}

class _CalvinLockHartState extends State<CalvinLockHart> {
  final FlutterLocalization _localization = FlutterLocalization.instance;
  late ThemeMode _themeMode;

  @override
  void initState() {
    super.initState();
    _localization.onTranslatedLanguage = (locale) {
      setState(() {});
    };
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getString('theme_mode') ?? 'light';
      setState(() {
        _themeMode = savedTheme == 'dark' ? ThemeMode.dark : ThemeMode.light;
      });
    } catch (_) {
      setState(() {
        _themeMode = ThemeMode.light;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          initialRoute: widget.isOfflineMode
              ? AppRoute.getOfflineDownloadsScreen()
              : (widget.isLoggedIn
                    ? AppRoute.getNavbarScreen()
                    : AppRoute.getSplashScreen()),
          getPages: AppRoute.routes,
          initialBinding: ControllerBinder(),
          locale: _localization.currentLocale,
          supportedLocales: _localization.supportedLocales,
          localizationsDelegates: _localization.localizationsDelegates,
          builder: EasyLoading.init(),
          themeMode: _themeMode,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
        );
      },
    );
  }
}
