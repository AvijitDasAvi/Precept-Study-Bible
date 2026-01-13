import 'package:calvinlockhart/core/common/widgets/custom_button.dart';
import 'package:calvinlockhart/core/utils/constants/icon_path.dart';
import 'package:calvinlockhart/core/utils/constants/image_path.dart';
import 'package:calvinlockhart/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:calvinlockhart/core/utils/localization/localization_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkForLoggedInUser();
  }

  Future<void> _checkForLoggedInUser() async {
    await Future.delayed(const Duration(milliseconds: 600));
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token') ?? '';
      if (token.isNotEmpty) {
        // Token exists, user is logged in
        Get.offAllNamed(AppRoute.getNavbarScreen());
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final horizontalPadding = size.width * 0.06;
    final logoHeight = size.height * 0.16;
    final textImageHeight = size.height * 0.07;
    final titleFontSize = (size.width / 20).clamp(16.0, 22.0).toDouble();
    final verseFontSize = (size.width / 24).clamp(14.0, 18.0).toDouble();

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(ImagePath.splashScreenBack),
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: size.height * 0.06,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: size.height - (size.height * 0.12),
              ),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: size.height * 0.12),
                    Image.asset(
                      IconPath.appLogo,
                      height: logoHeight,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: size.height * 0.02),
                    Image.asset(
                      ImagePath.splashScreenText,
                      height: textImageHeight,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: size.height * 0.08),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 0),
                      child: Text(
                        '"Through thy precepts I get understanding: therefore I hate every false way."',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF21252C),
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.01),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 0),
                      child: Text(
                        'Psalms 119:104',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: verseFontSize,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF383E4B),
                        ),
                      ),
                    ),
                    Spacer(),
                    Padding(
                      padding: EdgeInsets.only(bottom: size.height * 0.04),
                      child: CustomButton(
                        onTap: () {
                          Get.toNamed(AppRoute.signInScreen());
                        },
                        title: LocalizationService.translate('get_started'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
