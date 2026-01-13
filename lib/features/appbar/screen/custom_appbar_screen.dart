import 'package:flutter/material.dart';
import '../../../core/utils/constants/icon_path.dart';
import '../../../core/utils/constants/colors.dart';

class CustomAppBar extends AppBar {
  CustomAppBar({super.key, super.bottom})
    : super(
        backgroundColor: AppColors.primary,
        leadingWidth: 56,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(IconPath.appLogoWhite),
        ),
        title: const Text(
          'Precept Study Bible',
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
      );
}
