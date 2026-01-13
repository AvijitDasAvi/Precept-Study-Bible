import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? leading;
  final String? title;

  const CustomAppBar({this.leading, this.title});

  factory CustomAppBar.back() => CustomAppBar(
    leading: GestureDetector(
      onTap: () => Get.back(),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Color(0xFFF0F2F4),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 18),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: leading,
      title: title != null
          ? Text(title!, style: TextStyle(color: Colors.black87))
          : null,
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(56);
}
