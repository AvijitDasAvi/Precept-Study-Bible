import 'package:calvinlockhart/core/utils/constants/colors.dart';
import 'package:calvinlockhart/features/topics/screen/topics_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../home/screen/home_screen.dart';
import '../../bibles/all_bibles/screen/all_bibles_screen.dart';
import '../../profile/screen/profile_screen.dart';
import '../controller/navbar_controller.dart';
import '../../../core/utils/constants/icon_path.dart';
import 'package:calvinlockhart/core/utils/localization/localization_service.dart';

class NavbarScreen extends StatelessWidget {
  final NavbarController controller = Get.put(NavbarController());

  NavbarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final navBarBgColor = isDarkMode ? Color(0xFF1E1E1E) : Colors.white;
    final inactiveIconColor = isDarkMode ? Colors.grey[400] : Color(0xFF383E4B);
    final inactiveTextColor = isDarkMode ? Colors.grey[400] : Color(0xFF383E4B);
    final selectedBgColor = isDarkMode
        ? Color(0xFF334EA5).withValues(alpha: 0.15)
        : Color(0xFFEFF3FF);

    final pages = [
      HomeScreen(),
      AllBiblesScreen(),
      TopicsScreen(),
      ProfileScreen(),
    ];

    return Obx(
      () => Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: pages[controller.selectedIndex.value],
        bottomNavigationBar: SafeArea(
          bottom: true,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Material(
                color: navBarBgColor,
                elevation: 8,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(
                      4,
                      (index) => _buildItem(
                        index,
                        isDarkMode,
                        inactiveIconColor,
                        inactiveTextColor,
                        selectedBgColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItem(
    int index,
    bool isDarkMode,
    Color? inactiveIconColor,
    Color? inactiveTextColor,
    Color selectedBgColor,
  ) {
    final labels = [
      LocalizationService.translate('menu_home'),
      LocalizationService.translate('menu_bibles'),
      LocalizationService.translate('menu_topics'),
      LocalizationService.translate('menu_profile'),
    ];
    final icons = [
      IconPath.navHome,
      IconPath.navBibles,
      IconPath.navTopics,
      IconPath.navProfile,
    ];

    return Obx(() {
      final selected = controller.selectedIndex.value == index;
      return GestureDetector(
        onTap: () => controller.changeIndex(index),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? selectedBgColor : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: SvgPicture.asset(
                icons[index],
                width: 28,
                height: 28,
                color: selected
                    ? AppColors.primary
                    : (inactiveIconColor ?? Color(0xFF383E4B)),
              ),
            ),
            SizedBox(height: 6),
            Text(
              labels[index],
              style: TextStyle(
                fontSize: 12,
                color: selected
                    ? AppColors.primary
                    : (inactiveTextColor ?? Color(0xFF383E4B)),
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      );
    });
  }
}
