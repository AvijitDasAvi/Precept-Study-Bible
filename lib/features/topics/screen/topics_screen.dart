import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../appbar/screen/custom_appbar_screen.dart';
import '../../../core/utils/localization/localization_service.dart';
import '../widget/precept_topics.dart';
import '../widget/lesson_precepts.dart';
import '../widget/favorites.dart';
import '../controller/topics_controller.dart';

class TopicsScreen extends StatelessWidget {
  const TopicsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize the TopicsController globally if not already done
    if (!Get.isRegistered<TopicsController>()) {
      Get.put(TopicsController());
    }

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDarkMode ? Colors.black : Colors.white;
    final tabUnselectedColor = isDarkMode
        ? Colors.grey[400]
        : Color(0xFF8A99CB);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: CustomAppBar(
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(56),
            child: Center(
              child: TabBar(
                isScrollable: false,
                indicator: BoxDecoration(color: Colors.transparent),
                indicatorPadding: EdgeInsets.zero,
                labelPadding: EdgeInsets.symmetric(vertical: 6),
                labelColor: Colors.white,
                unselectedLabelColor: tabUnselectedColor,
                labelStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
                unselectedLabelStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                tabs: [
                  Tab(text: LocalizationService.translate('precepts_tab')),
                  Tab(text: LocalizationService.translate('lessons_tab')),
                  Tab(text: LocalizationService.translate('favorites_tab')),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            PreceptTopics(isDarkMode: isDarkMode),
            LessonPrecepts(isDarkMode: isDarkMode),
            Favorites(isDarkMode: isDarkMode),
          ],
        ),
      ),
    );
  }
}
