import 'package:flutter/material.dart';
import '../models/topic_models.dart';
import '../controller/topics_controller.dart';
import 'expanded_precept_widget.dart';

class PreceptItemWidget extends StatelessWidget {
  final PreceptModel precept;
  final String topicId;
  final TopicType type;
  final TopicsController controller;
  final VoidCallback? onToggleExpansion;
  final bool showAddNote;
  final bool isDarkMode;

  const PreceptItemWidget({
    super.key,
    required this.precept,
    required this.topicId,
    required this.type,
    required this.controller,
    this.onToggleExpansion,
    this.showAddNote = true,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        children: [
          _buildPreceptHeader(),
          if (precept.isExpanded) ...[
            SizedBox(height: 8),
            ExpandedPreceptWidget(
              precept: precept,
              topicId: topicId,
              type: type,
              controller: controller,
              showAddNote: showAddNote,
              isDarkMode: isDarkMode,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPreceptHeader() {
    final textColor = isDarkMode ? Colors.white : Color(0xFF21252C);
    final buttonBgColor = isDarkMode ? Colors.grey[800] : Color(0xFFEDEEF0);
    final buttonIconColor = isDarkMode ? Colors.grey[300] : Color(0xFF898F9B);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          fit: FlexFit.loose,
          child: Row(
            children: [
              Flexible(
                child: Text(
                  precept.reference,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 18,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w500,
                    height: 1.50,
                  ),
                ),
              ),
              SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  if (onToggleExpansion != null) {
                    onToggleExpansion!();
                  } else {
                    controller.togglePreceptExpansion(
                      topicId,
                      precept.id,
                      type,
                    );
                  }
                },
                child: Container(
                  width: 28,
                  height: 28,
                  padding: EdgeInsets.all(6),
                  decoration: ShapeDecoration(
                    color: buttonBgColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Icon(
                    precept.isExpanded ? Icons.remove : Icons.add,
                    size: 14,
                    color: buttonIconColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
