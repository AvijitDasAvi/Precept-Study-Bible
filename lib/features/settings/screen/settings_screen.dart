import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:calvinlockhart/core/utils/localization/localization_service.dart';
import 'package:calvinlockhart/features/settings/controller/settings_controller.dart';

class SettingsScreen extends StatelessWidget {
  final SettingsController controller = Get.put(SettingsController());

  SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDarkMode ? Colors.black : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final hintTextColor = isDarkMode ? Colors.white54 : Colors.black54;
    final dividerColor = isDarkMode ? Colors.grey[700] : Colors.grey;
    final appBarBgColor = isDarkMode ? Colors.grey[900] : Colors.white;
    final dropdownBgColor = isDarkMode ? Colors.grey[850] : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            size: 18,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
          onPressed: () => Get.back(),
        ),
        title: ValueListenableBuilder(
          valueListenable: LocalizationService.localeNotifier,
          builder: (_, __, ___) => Text(
            LocalizationService.translate('settings'),
            style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
          ),
        ),
        centerTitle: true,
        backgroundColor: appBarBgColor,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8),

            ValueListenableBuilder(
              valueListenable: LocalizationService.localeNotifier,
              builder: (_, __, ___) => Text(
                LocalizationService.translate('language'),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  fontSize: 16,
                ),
              ),
            ),
            SizedBox(height: 8),
            Obx(
              () => DropdownButton<String>(
                isExpanded: true,
                value: controller.selectedLanguage.value.isEmpty
                    ? null
                    : controller.selectedLanguage.value,
                hint: Text(
                  LocalizationService.translate('select_language'),
                  style: TextStyle(color: hintTextColor),
                ),
                items: <String>['English', 'Spanish']
                    .map(
                      (String value) => DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) controller.changeLanguage(value);
                },
                underline: SizedBox(),
                dropdownColor: dropdownBgColor,
                style: TextStyle(color: textColor),
              ),
            ),
            SizedBox(height: 20),

            Container(height: 1, color: dividerColor, width: double.infinity),
            SizedBox(height: 8),

            Obx(
              () => SwitchListTile(
                title: Text(
                  controller.themeMode.value == ThemeMode.dark
                      ? LocalizationService.translate('dark_mode')
                      : LocalizationService.translate('light_mode'),
                  style: TextStyle(color: textColor),
                ),
                value: controller.themeMode.value == ThemeMode.dark,
                onChanged: (isDarkMode) {
                  controller.toggleThemeMode(isDarkMode);
                },
                secondary: Icon(
                  controller.themeMode.value == ThemeMode.dark
                      ? Icons.dark_mode
                      : Icons.light_mode,
                  color: Colors.blue,
                ),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
