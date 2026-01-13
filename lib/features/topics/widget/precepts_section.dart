import 'package:flutter/material.dart';
import 'precept_controllers.dart';
import 'package:calvinlockhart/core/utils/localization/localization_service.dart';
import 'package:calvinlockhart/core/utils/constants/colors.dart';

class PreceptsSection extends StatelessWidget {
  final List<PreceptControllers> precepts;
  final bool isLoading;
  final void Function() onAdd;
  final void Function(int index) onRemove;
  final void Function(PreceptControllers controllers) onPreceptTitleChanged;

  const PreceptsSection({
    super.key,
    required this.precepts,
    required this.onAdd,
    required this.onRemove,
    required this.onPreceptTitleChanged,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              LocalizationService.translate('precepts'),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            IconButton(
              onPressed: isLoading ? null : onAdd,
              icon: Icon(Icons.add_circle, color: AppColors.primary),
            ),
          ],
        ),
        SizedBox(height: 8),
        ...precepts.asMap().entries.map((entry) {
          final index = entry.key;
          final precept = entry.value;
          return Container(
            margin: EdgeInsets.only(bottom: 16),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${LocalizationService.translate('precept')} ${index + 1}',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    if (precepts.length > 1)
                      IconButton(
                        onPressed: isLoading ? null : () => onRemove(index),
                        icon: Icon(Icons.remove_circle, color: Colors.red),
                      ),
                  ],
                ),
                SizedBox(height: 12),
                Stack(
                  children: [
                    TextFormField(
                      controller: precept.title,
                      enabled: !isLoading,
                      decoration: InputDecoration(
                        labelText: LocalizationService.translate(
                          'precept_title',
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: AppColors.primary),
                        ),
                      ),
                      onChanged: (_) => onPreceptTitleChanged(precept),
                    ),
                    if (precept.titleSuggestions.isNotEmpty)
                      Positioned(
                        top: 50,
                        left: 0,
                        right: 0,
                        child: Material(
                          elevation: 4,
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            constraints: BoxConstraints(maxHeight: 100),
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: precept.titleSuggestions.length,
                              itemBuilder: (context, suggestionIndex) {
                                final suggestion =
                                    precept.titleSuggestions[suggestionIndex];
                                return ListTile(
                                  title: Text(suggestion['name'] ?? ''),
                                  onTap: () {
                                    precept.title.text =
                                        suggestion['name'] ?? '';
                                    precept.titleSuggestions.clear();
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: precept.description,
                  enabled: !isLoading,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: LocalizationService.translate('precept_content'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
