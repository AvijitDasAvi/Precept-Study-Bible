import 'package:flutter/material.dart';
import '../../../core/utils/constants/colors.dart';
import 'package:calvinlockhart/core/utils/localization/localization_service.dart';

class SaveTopicButton extends StatelessWidget {
  final Future<void> Function() onSave;

  const SaveTopicButton({super.key, required this.onSave});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onSave,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 36, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Text(
            LocalizationService.translate('save'),
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
