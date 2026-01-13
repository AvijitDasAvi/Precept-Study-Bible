import 'package:flutter/material.dart';
import 'package:calvinlockhart/core/utils/localization/localization_service.dart';
import '../../../core/utils/constants/colors.dart';

class TopicNameInput extends StatelessWidget {
  final TextEditingController controller;
  final String? hint;
  final bool readOnly;

  const TopicNameInput({
    super.key,
    required this.controller,
    this.hint,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final hintTextColor = isDarkMode ? Colors.white54 : Colors.black54;
    final fillColor = isDarkMode ? Colors.grey[850] : Colors.white;
    final borderColor = isDarkMode ? Colors.grey[700] : Color(0xFFAEB2BA);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocalizationService.translate('topic_name_label'),
          style: TextStyle(color: AppColors.primary),
        ),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          readOnly: readOnly,
          decoration: InputDecoration(
            filled: true,
            fillColor: fillColor,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: borderColor ?? Color(0xFFAEB2BA)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: borderColor ?? Color(0xFFAEB2BA)),
            ),
            hintText: hint ?? LocalizationService.translate('topic_name_hint'),
            hintStyle: TextStyle(color: hintTextColor),
          ),
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ],
    );
  }
}
