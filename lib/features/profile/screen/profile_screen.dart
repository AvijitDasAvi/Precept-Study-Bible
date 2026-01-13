import 'package:calvinlockhart/core/common/styles/global_text_style.dart';
import 'package:calvinlockhart/core/utils/constants/icon_path.dart';
import 'package:calvinlockhart/features/profile/controller/profile_controller.dart';
import 'package:calvinlockhart/features/profile/widget/log_out_dailog_widget.dart';
import 'package:calvinlockhart/features/topics/widget/favorites.dart';
import 'package:calvinlockhart/features/topics/widget/lesson_precepts.dart';
import 'package:calvinlockhart/features/topics/widget/precept_topics.dart';
import 'package:calvinlockhart/features/topics/controller/topics_controller.dart';
import 'package:calvinlockhart/features/navbar/controller/navbar_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../downloads/screen/downloads_screen.dart';
import '../../../core/utils/localization/localization_service.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final ProfileController controller = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final headerBgColor = isDarkMode ? Colors.grey[850] : Color(0xFFE6E9F4);
    final textColor = isDarkMode ? Colors.white : Color(0xFF2B303A);
    final tileBgColor = isDarkMode ? Colors.black : Colors.white;
    final dividerColor = isDarkMode ? Colors.grey[800] : Colors.grey[300];

    return Scaffold(
      backgroundColor: tileBgColor,
      body: Obx(() {
        return SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                color: headerBgColor,
                padding: EdgeInsets.symmetric(vertical: 120),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: _avatarImageProvider(
                        controller.profileImage.value,
                      ),
                      onBackgroundImageError: (_, __) {},
                    ),
                    SizedBox(height: 16),
                    if (controller.userName.value.isNotEmpty) ...[
                      Text(
                        controller.userName.value,
                        style: getTextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: textColor,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        controller.userEmail.value,
                        style: getTextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: isDarkMode
                              ? Colors.grey[400]!
                              : Color(0xFF2B303A),
                        ),
                      ),
                    ] else ...[
                      Text(
                        controller.userEmail.value,
                        style: getTextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: textColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              _buildTile(
                icon: Image.asset(IconPath.profile2, width: 24, height: 24),
                text: LocalizationService.translate('account_setting'),
                onTap: () => Get.toNamed('/accountSetting'),
                isDarkMode: isDarkMode,
              ),
              Divider(height: 1, color: dividerColor),

              _buildTile(
                icon: Image.asset(IconPath.bookmark, width: 24, height: 24),
                text: LocalizationService.translate('topics'),
                onTap: () {
                  Get.offAllNamed('/navbar');
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    final navController = Get.find<NavbarController>();
                    navController.changeIndex(2);
                  });
                },
                isDarkMode: isDarkMode,
              ),
              _subTile(
                LocalizationService.translate('precept_topics'),
                onTap: () {
                  Get.to(() => _PreceptTopicsScreen(isDarkMode: isDarkMode));
                },
                isDarkMode: isDarkMode,
              ),
              _subTile(
                LocalizationService.translate('lesson_precepts'),
                onTap: () {
                  Get.to(() => _LessonPreceptsScreen(isDarkMode: isDarkMode));
                },
                isDarkMode: isDarkMode,
              ),
              _subTile(
                LocalizationService.translate('favorites'),
                onTap: () {
                  Get.to(() => _FavoritesScreen(isDarkMode: isDarkMode));
                },
                isDarkMode: isDarkMode,
              ),

              Divider(height: 1, color: dividerColor),

              ListTile(
                leading: Image.asset(
                  IconPath.downloadIcon,
                  width: 24,
                  height: 24,
                ),
                title: Text(
                  LocalizationService.translate('downloads'),
                  style: TextStyle(color: textColor),
                ),
                trailing: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                  decoration: BoxDecoration(
                    color: Color(0xFF00228E),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(IconPath.lock, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        LocalizationService.translate('unlocked'),
                        style: getTextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                onTap: () {
                  Get.to(() => DownloadsScreen());
                },
              ),
              Divider(height: 1, color: dividerColor),

              _buildTile(
                icon: Image.asset(IconPath.settings, width: 24, height: 24),
                text: LocalizationService.translate('settings'),
                onTap: () => Get.toNamed('/settingsScreen'),
                isDarkMode: isDarkMode,
              ),
              Divider(height: 1, color: dividerColor),

              _buildTile(
                icon: Image.asset(IconPath.logOut, width: 20, height: 20),
                text: LocalizationService.translate('log_out'),
                onTap: () {
                  LogoutDialog.showLogoutDialog(
                    icon: Image.asset(
                      IconPath.logoutIcon,
                      width: 44,
                      height: 44,
                    ),
                    message: LocalizationService.translate('logout_confirm'),
                    iconBgColor: Colors.red.withValues(alpha: 0.1),
                    onYes: () async {
                      try {
                        final prefs = await SharedPreferences.getInstance();
                        final savedEmail = prefs.getString('saved_email') ?? '';
                        if (savedEmail.isNotEmpty) {
                          await prefs.setString('saved_email', savedEmail);
                        }
                        await prefs.remove('saved_password');
                        await prefs.setBool('remember_me', false);
                        await prefs.remove('access_token');
                        await prefs.remove('user_email');
                        await prefs.remove('user_id');
                      } catch (_) {}
                      Get.back();
                      Get.offAllNamed('/signInScreen');
                    },
                    onNo: () => Get.back(),
                  );
                },
                isDarkMode: isDarkMode,
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildTile({
    required Widget icon,
    required String text,
    VoidCallback? onTap,
    required bool isDarkMode,
  }) {
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    return ListTile(
      leading: icon,
      title: Text(text, style: TextStyle(color: textColor)),
      onTap: onTap,
    );
  }

  Widget _subTile(
    String text, {
    VoidCallback? onTap,
    required bool isDarkMode,
  }) {
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final iconColor = isDarkMode ? Colors.grey[400] : Colors.black54;
    return Padding(
      padding: EdgeInsets.only(left: 40.0),
      child: ListTile(
        leading: Icon(Icons.filter_tilt_shift, color: iconColor),
        title: Text(text, style: TextStyle(color: textColor)),
        onTap: onTap,
      ),
    );
  }
}

ImageProvider _avatarImageProvider(String path) {
  if (path.isEmpty) return AssetImage(IconPath.profile2);

  final trimmed = path.trim();
  if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
    return NetworkImage(trimmed);
  }

  try {
    return AssetImage(trimmed);
  } catch (_) {
    return AssetImage(IconPath.profile2);
  }
}

class _PreceptTopicsScreen extends StatelessWidget {
  final bool isDarkMode;

  const _PreceptTopicsScreen({required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        title: Text(
          LocalizationService.translate('precept_topics'),
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF00228E),
        foregroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: GetBuilder<TopicsController>(
        init: TopicsController(),
        builder: (controller) => PreceptTopics(isDarkMode: isDarkMode),
      ),
    );
  }
}

class _LessonPreceptsScreen extends StatelessWidget {
  final bool isDarkMode;

  const _LessonPreceptsScreen({required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        title: Text(
          LocalizationService.translate('lesson_precepts'),
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF00228E),
        foregroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: GetBuilder<TopicsController>(
        init: TopicsController(),
        builder: (controller) => LessonPrecepts(isDarkMode: isDarkMode),
      ),
    );
  }
}

class _FavoritesScreen extends StatelessWidget {
  final bool isDarkMode;

  const _FavoritesScreen({required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        title: Text(
          LocalizationService.translate('favorites'),
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF00228E),
        foregroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: GetBuilder<TopicsController>(
        init: TopicsController(),
        builder: (controller) => Favorites(isDarkMode: isDarkMode),
      ),
    );
  }
}
