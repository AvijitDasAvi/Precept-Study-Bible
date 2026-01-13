import 'package:calvinlockhart/features/about/screen/about_screen.dart';
import 'package:calvinlockhart/features/accounts_setting/screen/accounts_setting_screen.dart';
import 'package:calvinlockhart/features/auth/forgot_pass/screen/provide_email.dart';
import 'package:calvinlockhart/features/auth/sign_in/screen/sign_in_screen.dart';
import 'package:calvinlockhart/features/auth/sign_up/screen/sign_up_screen.dart';
import 'package:calvinlockhart/features/auth/splash/screen/splash_screen.dart';
import 'package:calvinlockhart/features/information_update/screen/information_update_screen.dart';
import 'package:calvinlockhart/features/otp_verify/screen/otp_verify_screen.dart';
import 'package:calvinlockhart/features/auth/sign_up_email_verify/screen/sign_up_email_verify_screen.dart';
import 'package:calvinlockhart/features/auth/forgot_password_verify/screen/forgot_password_verify_screen.dart';
import 'package:calvinlockhart/features/auth/reset_password/screen/reset_password_screen.dart';
import 'package:calvinlockhart/features/password_security/screen/password_security_screen.dart';
import 'package:calvinlockhart/features/settings/screen/settings_screen.dart';
import 'package:calvinlockhart/features/share/screen/share_screen.dart';
import 'package:get/get.dart';
import 'package:calvinlockhart/features/navbar/screen/navbar_screen.dart';
import 'package:calvinlockhart/features/home/screen/home_screen.dart';
import 'package:calvinlockhart/features/bibles/all_bibles/screen/all_bibles_screen.dart';
import 'package:calvinlockhart/features/topics/screen/topics_screen.dart';
import 'package:calvinlockhart/features/profile/screen/profile_screen.dart';
import 'package:calvinlockhart/features/downloads/screen/downloads_screen.dart';


class AppRoute {
  static String splashScreen() => "/splashScreen";
  static String signInScreen() => "/signInScreen";
  static String signUpScreen() => "/signUpScreen";
  static String provideEmail() => "/provideEmail";
  static String navbarScreen() => "/navbar";
  static String homeScreen() => "/home";
  static String topicsScreen() => "/topics";
  static String profileScreen() => "/profile";
  static String accountSetting() => "/accountSetting";
  static String allBiblesScreen() => "/allBibles";
  static String informationUpdate() => "/informationUpdate";
  static String passwordSecurityScreen() => "/passwordSecurityScreen";
  static String otpVerifyScreen() => "/otpVerifyScreen";
  static String signUpEmailVerify() => "/auth/sign-up-verify";
  static String forgotPasswordVerify() => "/auth/forgot-password-verify";
  static String resetPassword() => "/auth/reset-password";
  static String settingsScreen() => "/settingsScreen";
  static String aboutScreen() => "/aboutScreen";
  static String shareScreen() => "/shareScreen";
  static String offlineDownloadsScreen() => "/offlineDownloads";

  static String getSplashScreen() => splashScreen();
  static String getSignInScreen() => signInScreen();
  static String getSignUpScreen() => signUpScreen();
  static String getProvideEmail() => provideEmail();
  static String getNavbarScreen() => navbarScreen();
  static String getHomeScreen() => homeScreen();
  static String getTopicsScreen() => topicsScreen();
  static String getProfileScreen() => profileScreen();
  static String getaccountSetting() => accountSetting();
  static String getAllBiblesScreen() => allBiblesScreen();
  static String getinformationUpdate() => informationUpdate();
  static String getswordSecurityScreen() => passwordSecurityScreen();
  static String getotpVerifyScreen() => otpVerifyScreen();
  static String getsignUpEmailVerify() => signUpEmailVerify();
  static String getForgotPasswordVerify() => forgotPasswordVerify();
  static String getResetPassword() => resetPassword();
  static String getsettingsScreen() => settingsScreen();
  static String getaboutScreen() => aboutScreen();
  static String getshareScreen() => shareScreen();
  static String getOfflineDownloadsScreen() => offlineDownloadsScreen();

  static List<GetPage> routes = [
    GetPage(
      name: splashScreen(),
      page: () => SplashScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: signInScreen(),
      page: () => SignInScreen(),
      transition: Transition.upToDown,
    ),
    GetPage(
      name: signUpScreen(),
      page: () => SignUpScreen(),
      transition: Transition.upToDown,
    ),
    GetPage(
      name: provideEmail(),
      page: () => const ProvideEmail(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: navbarScreen(),
      page: () => NavbarScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: homeScreen(),
      page: () => HomeScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: topicsScreen(),
      page: () => TopicsScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: profileScreen(),
      page: () => ProfileScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: accountSetting(),
      page: () => AccountSettingScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(name: allBiblesScreen(), page: () => AllBiblesScreen()),
    GetPage(
      name: informationUpdate(),
      page: () => InformationUpdateScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: passwordSecurityScreen(),
      page: () => PasswordSecurityScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: otpVerifyScreen(),
      page: () => OtpVerifyScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: signUpEmailVerify(),
      page: () => SignUpEmailVerifyScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: forgotPasswordVerify(),
      page: () => ForgotPasswordVerifyScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: resetPassword(),
      page: () => ResetPasswordScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: settingsScreen(),
      page: () => SettingsScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: aboutScreen(),
      page: () => AboutScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: shareScreen(),
      page: () => ShareScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: offlineDownloadsScreen(),
      page: () => DownloadsScreen(),
      transition: Transition.fadeIn,
    ),
  ];
}
