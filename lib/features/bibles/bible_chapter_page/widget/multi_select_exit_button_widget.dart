import 'package:flutter/material.dart';

class MultiSelectExitButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isDarkMode;

  const MultiSelectExitButton({
    super.key,
    required this.onPressed,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = isDarkMode ? Colors.white : Colors.black;

    return Align(
      alignment: Alignment.topRight,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: IconButton(
            tooltip: 'Exit selection',
            onPressed: onPressed,
            icon: Icon(Icons.close, color: iconColor),
          ),
        ),
      ),
    );
  }
}
