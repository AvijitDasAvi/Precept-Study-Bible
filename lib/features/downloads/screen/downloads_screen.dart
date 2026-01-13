import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controller/downloads_controller.dart';
import '../../topics/widget/topic_card.dart';
import '../../topics/controller/topics_controller.dart';
import '../../topics/models/topic_models.dart';
import '../../../routes/app_routes.dart';

class DownloadsScreen extends StatelessWidget {
  const DownloadsScreen({super.key});

  DownloadsController _getController() {
    if (Get.isRegistered<DownloadsController>()) {
      return Get.find<DownloadsController>();
    }
    return Get.put(DownloadsController(), permanent: true);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDarkMode ? Colors.black : Colors.white;
    final appBarBgColor = isDarkMode ? Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    final controller = _getController();
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: appBarBgColor,
        title: Text('Downloads', style: TextStyle(color: textColor)),
        automaticallyImplyLeading: true,
        iconTheme: IconThemeData(color: textColor),
        actions: [
          IconButton(
            onPressed: _handleLogout,
            icon: Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Obx(() {
        final items = controller.downloads;
        if (items.isEmpty) {
          return Center(
            child: Text('No downloads', style: TextStyle(color: textColor)),
          );
        }
        return ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final t = items[index];
            final precepts = (t.precepts)
                .map(
                  (p) => PreceptModel(
                    id: p['id'] ?? '',
                    reference: p['reference'] ?? '',
                    content: p['content'] ?? '',
                  ),
                )
                .toList();
            final topicModel = TopicModel(
              id: t.id,
              title: t.title,
              createdAt: t.createdAt,
              precepts: precepts,
            );

            final topicsController = Get.isRegistered<TopicsController>()
                ? Get.find<TopicsController>()
                : Get.put(TopicsController());

            return TopicCard(
              topic: topicModel,
              type: TopicType.preceptTopics,
              controller: topicsController,
              showAddPrecepts: false,
              showAddNote: false,
              isDarkMode: isDarkMode,
              onDelete: () async {
                try {
                  await controller.removeDownload(t.id);
                  EasyLoading.showSuccess('Download removed');
                } catch (e) {
                  debugPrint('Error removing download: $e');
                }
              },
            );
          },
        );
      }),
    );
  }

  Future<void> _handleLogout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      Get.offAllNamed(AppRoute.getSplashScreen());
      EasyLoading.showSuccess('Logged out successfully');
    } catch (e) {
      debugPrint('Error logging out: $e');
    }
  }
}
