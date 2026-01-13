import 'package:flutter/material.dart';

class ChapterNavigationButtons extends StatelessWidget {
  final VoidCallback onPrevPressed;
  final VoidCallback onNextPressed;
  final bool isDarkMode;

  const ChapterNavigationButtons({
    super.key,
    required this.onPrevPressed,
    required this.onNextPressed,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final buttonBgColor = isDarkMode ? Colors.grey[800] : Colors.white;
    const primaryBlue = Color(0xFF00228E);

    return Stack(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: Semantics(
              label: 'Previous chapter',
              child: FloatingActionButton(
                heroTag: 'prev_chapter',
                mini: true,
                backgroundColor: buttonBgColor,
                onPressed: onPrevPressed,
                child: Icon(
                  Icons.arrow_back_ios_new,
                  color: primaryBlue,
                  size: 18,
                ),
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: EdgeInsets.only(right: 8.0),
            child: Semantics(
              label: 'Next chapter',
              child: FloatingActionButton(
                heroTag: 'next_chapter',
                mini: true,
                backgroundColor: buttonBgColor,
                onPressed: onNextPressed,
                child: Icon(
                  Icons.arrow_forward_ios,
                  color: primaryBlue,
                  size: 18,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
