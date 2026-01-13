import 'package:flutter/material.dart';
import 'package:calvinlockhart/core/utils/localization/localization_service.dart';
import '../../../core/utils/constants/colors.dart';

class DestinationSelector extends StatelessWidget {
  final int? selected;
  final void Function(int) onSelected;

  const DestinationSelector({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocalizationService.translate('select_destination'),
          style: TextStyle(color: AppColors.primary),
        ),
        SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _destButton(LocalizationService.translate('precept_topic'), 0),
              SizedBox(width: 8),
              _destButton(LocalizationService.translate('lesson_precepts'), 1),
              SizedBox(width: 8),
              _destButton(LocalizationService.translate('favorite'), 2),
            ],
          ),
        ),
      ],
    );
  }

  Widget _destButton(String label, int id) {
    final bool selected = this.selected == id;
    return GestureDetector(
      onTap: () => onSelected(id),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? Color(0xFFE6E9F4) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? Color(0xFF334EA5) : Color(0xFFE6E9F4),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
