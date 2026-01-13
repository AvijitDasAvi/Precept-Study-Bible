import 'package:flutter/material.dart';
import 'package:calvinlockhart/core/utils/localization/localization_service.dart';
import 'package:calvinlockhart/features/home/widget/precept_controllers.dart';

class PreceptsSection extends StatelessWidget {
  final List<PreceptControllers> precepts;
  final void Function(PreceptControllers) onAddPrecept;
  final void Function(int) onRemovePrecept;
  final void Function(int, PreceptControllers) onAttachListener;
  final void Function()? onAddFromBooks;
  final bool allowRemove;
  final bool isEditing;

  const PreceptsSection({
    super.key,
    required this.precepts,
    required this.onAddPrecept,
    required this.onRemovePrecept,
    required this.onAttachListener,
    this.onAddFromBooks,
    this.allowRemove = false,
    this.isEditing = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Color(0xFF334EA5);
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final hintTextColor = isDarkMode ? Colors.white54 : Colors.black54;
    final fillColor = isDarkMode ? Colors.grey[850] : Colors.white;
    final borderColor = isDarkMode ? Colors.grey[700] : Color(0xFFBFC6CF);
    final buttonBgColor = isDarkMode ? Colors.grey[800] : Color(0xFFE6E9F4);
    final suggestionsBgColor = isDarkMode ? Colors.grey[800] : Colors.white;

    if (precepts.isEmpty) {
      return GestureDetector(
        onTap: () {
          final p = PreceptControllers();
          onAttachListener(precepts.length, p);
          onAddPrecept(p);
        },
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: buttonBgColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.add, color: primaryColor),
              SizedBox(width: 8),
              Text(
                LocalizationService.translate('add_precept'),
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              LocalizationService.translate('precepts_label'),
              style: TextStyle(color: primaryColor),
            ),
            if (onAddFromBooks != null && !isEditing)
              GestureDetector(
                onTap: onAddFromBooks,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.library_books, color: Colors.white, size: 16),
                      SizedBox(width: 6),
                      Text(
                        'Add from Books',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: 8),
        ...precepts.asMap().entries.map((entry) {
          final idx = entry.key;
          final ctrl = entry.value;
          return Padding(
            key: ValueKey('precept_$idx'),
            padding: EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: ctrl.title,
                      readOnly:
                          isEditing && (ctrl.preceptId?.isNotEmpty ?? false),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: fillColor,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: borderColor ?? Color(0xFFBFC6CF),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: borderColor ?? Color(0xFFBFC6CF),
                          ),
                        ),
                        hintText: LocalizationService.translate(
                          'precept_title_hint',
                        ),
                        hintStyle: TextStyle(color: hintTextColor),
                      ),
                      style: TextStyle(fontSize: 16, color: textColor),
                    ),
                    if (ctrl.titleSuggestions.isNotEmpty)
                      Container(
                        margin: EdgeInsets.only(top: 4),
                        padding: EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: suggestionsBgColor,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(color: Colors.black12, blurRadius: 8),
                          ],
                        ),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxHeight: 150),
                          child: ListView.separated(
                            shrinkWrap: true,
                            itemCount: ctrl.titleSuggestions.length,
                            separatorBuilder: (_, __) => Divider(
                              height: 1,
                              color: isDarkMode
                                  ? Colors.grey[700]
                                  : Colors.grey[300],
                            ),
                            itemBuilder: (context, sugIndex) {
                              final suggestion =
                                  ctrl.titleSuggestions[sugIndex];
                              final bookName =
                                  suggestion['name']?.toString() ?? '';
                              final chapters =
                                  suggestion['chapters']?.toString() ?? '';
                              return ListTile(
                                dense: true,
                                title: Text(
                                  bookName,
                                  style: TextStyle(color: textColor),
                                ),
                                subtitle: Text(
                                  '$chapters chapters',
                                  style: TextStyle(color: hintTextColor),
                                ),
                                onTap: () {
                                  ctrl.suppressTitleSuggestions = true;
                                  ctrl.lastSelectedTitleText = bookName;
                                  ctrl.title.text = bookName;
                                  ctrl.titleSuggestions.clear();
                                },
                              );
                            },
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: ctrl.description,
                        minLines: 4,
                        maxLines: 10,
                        readOnly: false,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: fillColor,
                          contentPadding: EdgeInsets.all(12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: borderColor ?? Color(0xFFBFC6CF),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: borderColor ?? Color(0xFFBFC6CF),
                            ),
                          ),
                        ),
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.4,
                          color: textColor,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    if (allowRemove)
                      GestureDetector(
                        onTap: () => onRemovePrecept(idx),
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: fillColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.close, color: primaryColor),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          );
        }),
        if (!isEditing)
          GestureDetector(
            onTap: _hasEmptyLastPrecept(precepts)
                ? null
                : () {
                    final p = PreceptControllers();
                    onAttachListener(precepts.length, p);
                    onAddPrecept(p);
                  },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _hasEmptyLastPrecept(precepts)
                    ? Colors.grey[400]
                    : buttonBgColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.add,
                    color: _hasEmptyLastPrecept(precepts)
                        ? Colors.grey[600]
                        : primaryColor,
                  ),
                  SizedBox(width: 8),
                  Text(
                    LocalizationService.translate('add_precept'),
                    style: TextStyle(
                      color: _hasEmptyLastPrecept(precepts)
                          ? Colors.grey[600]
                          : textColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (isEditing)
          GestureDetector(
            onTap: () {
              final p = PreceptControllers();
              onAttachListener(precepts.length, p);
              onAddPrecept(p);
            },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: buttonBgColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.add, color: primaryColor),
                  SizedBox(width: 8),
                  Text(
                    LocalizationService.translate('add_precept'),
                    style: TextStyle(color: textColor),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  bool _hasEmptyLastPrecept(List<PreceptControllers> precepts) {
    if (precepts.isEmpty) return false;
    final lastPrecept = precepts.last;
    return lastPrecept.title.text.trim().isEmpty ||
        lastPrecept.description.text.trim().isEmpty;
  }
}
