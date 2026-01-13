import 'package:flutter/material.dart';
import '../models/topic_models.dart';
import '../controller/topics_controller.dart';
import '../../home/widget/add_topic_dialog.dart';

class CreateTopicButton extends StatelessWidget {
  final TopicsController controller;
  final TopicType type;

  const CreateTopicButton({
    super.key,
    required this.controller,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showCreateTopicDialog(context),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(12),
        decoration: ShapeDecoration(
          color: Color(0xFFE6E9F4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, size: 24, color: Color(0xFF00228E)),
            SizedBox(width: 8),
            Text(
              'Add Precepts',
              style: TextStyle(
                color: Color(0xFF00228E),
                fontSize: 18,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w600,
                height: 1.50,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateTopicDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) =>
          Dialog(insetPadding: EdgeInsets.all(20), child: AddTopicDialog()),
    );
  }
}
