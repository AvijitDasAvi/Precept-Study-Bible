import 'package:calvinlockhart/core/common/styles/global_text_style.dart';
import 'package:calvinlockhart/core/utils/constants/icon_path.dart';
import 'package:calvinlockhart/features/accounts_setting/controller/accounts_setting_controller.dart';
import 'package:calvinlockhart/core/utils/localization/localization_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AccountSettingScreen extends StatelessWidget {
  AccountSettingScreen({super.key});

  final controller = Get.put(AccountSettingController());

  Widget _buildTile({
    required Widget icon,
    required String text,
    required VoidCallback onTap,
    TextStyle? textStyle,
    Color? tileColor,
    EdgeInsetsGeometry? padding,
    required bool isDarkMode,
  }) {
    final dividerColor = isDarkMode ? Colors.grey[800] : Colors.black12;

    return Column(
      children: [
        Container(
          color: tileColor ?? (isDarkMode ? Colors.grey[900] : Colors.white),
          child: ListTile(
            leading: icon,
            title: Text(
              text,
              style:
                  textStyle ??
                  getTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
            ),
            onTap: onTap,
            contentPadding: padding ?? EdgeInsets.symmetric(horizontal: 16),
          ),
        ),
        Divider(height: 1, thickness: 0.5, color: dividerColor),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDarkMode ? Colors.black : Colors.white;
    final appBarBgColor = isDarkMode ? Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Color(0xFF21252C);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: appBarBgColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 18, color: textColor),
          onPressed: () => Get.back(),
        ),
        title: Text(
          LocalizationService.translate('account_setting'),
          style: getTextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildTile(
            icon: Image.asset(IconPath.profile2, width: 14, height: 14),
            text: LocalizationService.translate('information_update'),
            onTap: controller.goToInformationUpdate,
            textStyle: getTextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: textColor,
            ),
            isDarkMode: isDarkMode,
          ),
          _buildTile(
            icon: Image.asset(
              IconPath.lock,
              color: textColor,
              width: 24,
              height: 24,
            ),
            text: LocalizationService.translate('password_and_security'),
            onTap: controller.goToPasswordSecurity,
            textStyle: getTextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: textColor,
            ),
            isDarkMode: isDarkMode,
          ),
        ],
      ),
    );
  }
}
