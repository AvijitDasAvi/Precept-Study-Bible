import 'package:calvinlockhart/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/utils/localization/localization_service.dart';
import '../../all_bibles/controller/all_bibles_controller.dart';
import '../controller/bible_chapter_state_controller.dart';

class BibleChapterAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final Book book;
  final String currentVersion;
  final ValueChanged<String> onVersionChanged;
  final VoidCallback onBackPressed;
  final bool isDarkMode;
  final bool hasSpanishData;

  const BibleChapterAppBar({
    super.key,
    required this.book,
    required this.currentVersion,
    required this.onVersionChanged,
    required this.onBackPressed,
    required this.isDarkMode,
    this.hasSpanishData = false,
  });

  @override
  Widget build(BuildContext context) {
    final title = book.title;
    final versions = BibleChapterStateController.availableVersions();

    // Add Spanish if available
    final allVersions = [...versions];
    if (hasSpanishData && !allVersions.contains('Spanish')) {
      allVersions.add('Spanish');
    }

    final appBarBgColor = isDarkMode ? Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Color(0xFF21252C);
    final buttonBgColor = isDarkMode ? Colors.grey[800] : Color(0xFFEDEEF0);

    return AppBar(
      backgroundColor: appBarBgColor,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: textColor),
        onPressed: onBackPressed,
      ),
      centerTitle: true,
      title: Text(title, style: TextStyle(color: textColor)),
      actions: [
        IconButton.filled(
          icon: Icon(Icons.home, color: textColor),
          style: IconButton.styleFrom(
            backgroundColor: buttonBgColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () {
            Get.offAllNamed(AppRoute.navbarScreen());
          },
        ),
        Padding(
          padding: EdgeInsets.only(right: 12.0),
          child: Material(
            color: buttonBgColor,
            borderRadius: BorderRadius.circular(8),
            child: PopupMenuButton<String>(
              tooltip: LocalizationService.translate('select_version'),
              onSelected: onVersionChanged,
              itemBuilder: (ctx) => allVersions
                  .map((v) => PopupMenuItem(value: v, child: Text(v)))
                  .toList(),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    Text(currentVersion, style: TextStyle(color: textColor)),
                    SizedBox(width: 6),
                    Icon(Icons.arrow_drop_down, color: textColor),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
