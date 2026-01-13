import 'package:flutter/material.dart';
import 'package:calvinlockhart/core/utils/localization/localization_service.dart';
import '../../../core/utils/constants/colors.dart';

class AddTopicHeader extends StatelessWidget {
  final bool showFromSelected;
  final VoidCallback onClose;

  const AddTopicHeader({
    super.key,
    required this.showFromSelected,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LocalizationService.translate('add_topic'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
            if (showFromSelected)
              Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  LocalizationService.translate('from_selected_bible'),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
        GestureDetector(
          onTap: onClose,
          child: Icon(Icons.close, color: textColor),
        ),
      ],
    );
  }
}
