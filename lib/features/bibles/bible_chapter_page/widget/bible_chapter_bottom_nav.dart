import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/utils/constants/icon_path.dart';

class BibleChapterBottomNav extends StatelessWidget {
  final List<String>? paragraphs;
  final int? selectedParaIndex;
  final bool isPlaying;
  final bool repeatSingle;
  final VoidCallback onCopyPressed;
  final VoidCallback onSharePressed;
  final VoidCallback onPlayPressed;
  final VoidCallback onRepeatPressed;
  final bool isDarkMode;

  const BibleChapterBottomNav({
    super.key,
    required this.paragraphs,
    required this.selectedParaIndex,
    required this.isPlaying,
    required this.repeatSingle,
    required this.onCopyPressed,
    required this.onSharePressed,
    required this.onPlayPressed,
    required this.onRepeatPressed,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final navBgColor = isDarkMode ? Color(0xFF1E1E1E) : Colors.white;
    final shadowColor = Colors.black.withValues(alpha: 0.04);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: navBgColor,
        boxShadow: [
          BoxShadow(color: shadowColor, blurRadius: 18, offset: Offset(0, -2)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: onCopyPressed,
            icon: SvgPicture.asset(IconPath.copyIcon, width: 24, height: 24),
          ),
          IconButton(
            onPressed: onSharePressed,
            icon: SvgPicture.asset(IconPath.shareIcon, width: 24, height: 24),
          ),
          IconButton(
            onPressed: onPlayPressed,
            icon: isPlaying
                ? SvgPicture.asset(IconPath.pauseIcon, width: 28, height: 28)
                : SvgPicture.asset(IconPath.playIcon, width: 28, height: 28),
          ),
          IconButton(
            onPressed: onRepeatPressed,
            icon: SvgPicture.asset(
              IconPath.repeatIcon,
              width: 24,
              height: 24,
              color: repeatSingle ? Color(0xFF00228E) : null,
            ),
          ),
        ],
      ),
    );
  }
}
