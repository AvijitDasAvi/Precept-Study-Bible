import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../navbar/widget/advertisement_banner.dart';
import '../controller/topics_controller.dart';
import '../models/topic_models.dart';
import 'topic_card.dart';
import 'topics_search_bar.dart';
import '../../home/widget/add_topic_dialog.dart';

class LessonPrecepts extends StatelessWidget {
  final bool isDarkMode;

  const LessonPrecepts({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final bgColor = isDarkMode ? Colors.black : Colors.white;

    return GetBuilder<TopicsController>(
      builder: (controller) {
        return Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              color: bgColor,
              child: TopicsSearchBar(
                controller: controller,
                isDarkMode: isDarkMode,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => Dialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: AddTopicDialog(),
                      ),
                    );
                  },
                  icon: Icon(Icons.add),
                  label: Text('Create Topic'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF334EA5),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ),

            Expanded(
              child: Container(
                color: bgColor,
                child: ReorderableListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  itemCount: controller.lessonPrecepts.length,
                  onReorder: (oldIndex, newIndex) {
                    controller.reorderTopics(
                      oldIndex,
                      newIndex,
                      TopicType.lessonPrecepts,
                    );
                  },
                  itemBuilder: (context, index) {
                    final topic = controller.lessonPrecepts[index];
                    return TopicCard(
                      key: ValueKey(topic.id),
                      topic: topic,
                      type: TopicType.lessonPrecepts,
                      controller: controller,
                      isDarkMode: isDarkMode,
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 20, right: 20, bottom: 16),
              child: AdvertisementBanner(horizontalPadding: 20, onTap: () {}),
            ),
          ],
        );
      },
    );
  }
}
