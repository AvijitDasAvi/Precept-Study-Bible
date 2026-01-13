import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../all_bibles/controller/all_bibles_controller.dart';
import '../controller/bible_chapter_state_controller.dart';
import '../widget/bible_chapter_app_bar.dart';
import '../widget/bible_chapter_body.dart';
import '../widget/bible_chapter_bottom_nav.dart';
import '../widget/chapter_navigation_buttons_widget.dart';
import '../widget/multi_select_exit_button_widget.dart';
import '../../../navbar/widget/advertisement_banner.dart';

class BibleChapterPageScreen extends StatelessWidget {
  final Book book;
  final int chapter;
  final String version;
  final bool hasSpanishData;

  const BibleChapterPageScreen({
    super.key,
    required this.book,
    required this.chapter,
    required this.version,
    this.hasSpanishData = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDarkMode ? Colors.black : Colors.white;

    final tag = '${book.id}_${chapter}_$version';
    final controller = Get.put(
      BibleChapterStateController(
        book: book,
        initialChapter: chapter,
        initialVersion: version,
      ),
      tag: tag,
    );

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          controller.pausePlayback();
        }
      },
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: Obx(
            () => BibleChapterAppBar(
              book: book,
              currentVersion: controller.currentVersion,
              onVersionChanged: controller.onChangeVersion,
              onBackPressed: () {
                controller.pausePlayback();
                try {
                  Get.delete<BibleChapterStateController>(tag: tag);
                } catch (_) {}
                Navigator.of(context).maybePop();
              },
              isDarkMode: isDarkMode,
              hasSpanishData: hasSpanishData,
            ),
          ),
        ),
        body: Obx(() {
          final paras = controller.lastParagraphs ?? [];
          if (paras.isEmpty) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(
                  isDarkMode ? Colors.white : Colors.blue,
                ),
              ),
            );
          }
          return Stack(
            children: [
              BibleChapterBody(
                book: book,
                chapter: controller.currentChapter,
                paragraphs: paras,
                selectedParaIndex: controller.selectedParaIndex,
                selectedParas: controller.selectedParas,
                paraKeys: controller.paraKeys,
                onParagraphTap: controller.onParagraphTap,
                onParagraphLongPress: controller.onParagraphLongPress,
                onAddPressed: controller.onAddToTopic,
                isDarkMode: isDarkMode,
              ),
              ChapterNavigationButtons(
                onPrevPressed: controller.goPrevChapter,
                onNextPressed: controller.goNextChapter,
                isDarkMode: isDarkMode,
              ),
              if (controller.multiSelectMode)
                MultiSelectExitButton(
                  onPressed: controller.exitMultiSelect,
                  isDarkMode: isDarkMode,
                ),
            ],
          );
        }),
        bottomNavigationBar: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: AdvertisementBanner(horizontalPadding: 20, onTap: () {}),
              ),
              Obx(
                () => BibleChapterBottomNav(
                  paragraphs: controller.lastParagraphs,
                  selectedParaIndex: controller.selectedParaIndex,
                  isPlaying: controller.isPlaying,
                  repeatSingle: controller.repeatSingle,
                  onCopyPressed: controller.copySelectedText,
                  onSharePressed: controller.shareSelectedText,
                  onPlayPressed: controller.playSelectedText,
                  onRepeatPressed: controller.toggleRepeat,
                  isDarkMode: isDarkMode,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
