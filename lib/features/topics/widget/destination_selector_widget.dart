import 'package:flutter/material.dart';
import 'package:calvinlockhart/core/utils/localization/localization_service.dart';

class DestinationSelectorWidget extends StatelessWidget {
  final int? selected;
  final bool isLoading;
  final void Function(int? value) onChanged;

  const DestinationSelectorWidget({
    super.key,
    required this.selected,
    required this.onChanged,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocalizationService.translate('select_destination'),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 8),
        Column(
          children: [
            _buildOption(
              context,
              label: LocalizationService.translate('precept_topic'),
              value: 0,
            ),
            _buildOption(
              context,
              label: LocalizationService.translate('lesson_precepts'),
              value: 1,
            ),
            _buildOption(
              context,
              label: LocalizationService.translate('favorites'),
              value: 2,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required String label,
    required int value,
  }) {
    final bool isSelected = selected == value;

    return InkWell(
      onTap: isLoading
          ? null
          : () {
              onChanged(value);
            },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Colors.grey.shade400,
                  width: 2,
                ),
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.transparent,
              ),
              child: isSelected
                  ? Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: isLoading ? Colors.grey : Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
