import 'package:flutter/material.dart';
import '../models/topic_models.dart';
import '../controller/topics_controller.dart';
import '../../../core/datetime_format.dart';

class TopicCardHeader extends StatelessWidget {
  final TopicModel topic;
  final TopicType type;
  final TopicsController controller;
  final VoidCallback? onDelete;
  final VoidCallback onMenuTap;
  final bool showMenu;
  final bool isDarkMode;

  const TopicCardHeader({
    super.key,
    required this.topic,
    required this.type,
    required this.controller,
    required this.onMenuTap,
    required this.showMenu,
    required this.isDarkMode,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final dateTextColor = isDarkMode ? Colors.grey[400] : Color(0xFF898F9B);
    final menuIconColor = isDarkMode ? Colors.grey[400] : Color(0xFF898F9B);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                topic.title,
                style: TextStyle(
                  color: Color(0xFF00228E),
                  fontSize: 20,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w600,
                  height: 1.50,
                ),
              ),
              Text(
                DatetimeFormat.formatUtcToLocal(topic.createdAt),
                style: TextStyle(
                  color: dateTextColor,
                  fontSize: 12,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w400,
                  height: 1.50,
                ),
              ),
            ],
          ),
        ),
        onDelete != null
            ? GestureDetector(
                onTap: onDelete,
                child: Container(
                  width: 28,
                  height: 28,
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Icons.delete_outline,
                    size: 20,
                    color: Color(0xFFDC2626),
                  ),
                ),
              )
            : GestureDetector(
                onTap: onMenuTap,
                child: Container(
                  width: 24,
                  height: 24,
                  padding: EdgeInsets.all(2),
                  child: Icon(Icons.more_vert, size: 20, color: menuIconColor),
                ),
              ),
      ],
    );
  }
}
