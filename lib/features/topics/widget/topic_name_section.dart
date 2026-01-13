import 'package:flutter/material.dart';
import 'package:calvinlockhart/core/utils/localization/localization_service.dart';
import 'package:calvinlockhart/core/utils/constants/colors.dart';

class TopicNameSection extends StatelessWidget {
  final TextEditingController controller;
  final List<Map<String, dynamic>> suggestions;
  final bool enabled;
  final bool showTopicNameError;
  final void Function(Map<String, dynamic> suggestion) onSuggestionSelected;

  const TopicNameSection({
    super.key,
    required this.controller,
    required this.suggestions,
    required this.onSuggestionSelected,
    this.enabled = true,
    this.showTopicNameError = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocalizationService.translate('topic_name'),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 8),
        Stack(
          children: [
            TextFormField(
              controller: controller,
              enabled: enabled,
              decoration: InputDecoration(
                hintText: LocalizationService.translate('topic_name_hint'),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.primary),
                ),
                errorText: showTopicNameError
                    ? LocalizationService.translate('topic_name_required')
                    : null,
              ),
            ),
            if (suggestions.isNotEmpty)
              Positioned(
                top: 50,
                left: 0,
                right: 0,
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    constraints: BoxConstraints(maxHeight: 150),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: suggestions.length,
                      itemBuilder: (context, index) {
                        final suggestion = suggestions[index];
                        return ListTile(
                          title: Text(suggestion['name'] ?? ''),
                          subtitle: Text(
                            (suggestion['destination'] ?? '').toString(),
                          ),
                          onTap: () => onSuggestionSelected(suggestion),
                        );
                      },
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
