import 'package:calvinlockhart/core/utils/constants/colors.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback? onTap;
  final String? title;
  final Widget? titleWidget;
  final EdgeInsetsGeometry? padding;
  final BorderRadiusGeometry? borderRadius;

  const CustomButton({
    super.key,
    required this.onTap,
    this.title,
    this.titleWidget,
    this.padding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final bool enabled = onTap != null;

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Material(
        elevation: 4.0,
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        child: Container(
          padding:
              padding ??
              const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
          decoration: BoxDecoration(
            color: enabled ? AppColors.primary : Colors.grey,
            borderRadius: borderRadius ?? BorderRadius.circular(12),
          ),
          child:
              titleWidget ??
              Text(
                title ?? '',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFE6EFF9),
                ),
              ),
        ),
      ),
    );
  }
}
