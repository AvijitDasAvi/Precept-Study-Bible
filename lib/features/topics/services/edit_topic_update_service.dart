import 'package:flutter/material.dart';
import '../controller/topics_controller.dart';
import '../models/topic_models.dart';
import '../widget/precept_controllers.dart';
// ...existing code...
import 'package:flutter_easyloading/flutter_easyloading.dart';

class EditTopicUpdateService {
  static Future<void> updateTopic({
    required BuildContext context,
    required String topicId,
    required String topicName,
    required String? selectedTopicId,
    required int? selectedDestination,
    required List<PreceptControllers> precepts,
    required TopicsController controller,
    required TopicType type,
    required VoidCallback onLoadingStart,
    required VoidCallback onLoadingEnd,
  }) async {
    onLoadingStart();

    try {
      final dest = selectedDestination == 0
          ? 'PRECEPT_TOPIC'
          : selectedDestination == 1
          ? 'LESSON_PRECEPTS'
          : 'FAVORITES';

      final List<Map<String, String>> preceptPayload = precepts
          .where(
            (c) =>
                c.title.text.trim().isNotEmpty &&
                c.description.text.trim().isNotEmpty,
          )
          .map(
            (c) => {
              'reference': c.title.text.trim(),
              'content': c.description.text.trim(),
            },
          )
          .toList();

      final success = await controller.editTopic(
        topicId,
        selectedTopicId?.isNotEmpty == true ? selectedTopicId! : topicName,
        dest,
        preceptPayload,
        type,
      );

      onLoadingEnd();

      if (success) {
        Navigator.of(context).pop();
        EasyLoading.showSuccess('Topic updated successfully');
      } else {
        EasyLoading.showError('Failed to update topic. Please try again.');
      }
    } catch (e) {
      debugPrint('Error updating topic: $e');
      onLoadingEnd();
      EasyLoading.showError('An unexpected error occurred. Please try again.');
    }
  }

  static bool validateTopic({
    required String topicName,
    required String? selectedTopicId,
    required int? selectedDestination,
    required List<PreceptControllers> precepts,
    required Function(
      bool showTopicNameError,
      bool showDestinationError,
      bool showError,
    )
    onValidationResult,
  }) {
    final showTopicNameError =
        topicName.isEmpty &&
        (selectedTopicId == null || selectedTopicId.isEmpty);
    final showDestinationError = selectedDestination == null;
    final showError = precepts.any(
      (p) => p.title.text.trim().isEmpty || p.description.text.trim().isEmpty,
    );

    onValidationResult(showTopicNameError, showDestinationError, showError);

    final hasDestination = selectedDestination != null;
    final hasValidTopic =
        topicName.isNotEmpty ||
        (selectedTopicId != null && selectedTopicId.isNotEmpty);

    return hasValidTopic && hasDestination && !showError;
  }
}
