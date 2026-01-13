import 'package:flutter/material.dart';

import '../../all_bibles/controller/all_bibles_controller.dart';
import '../controller/bible_chapter_state_controller.dart';
import 'bible_chapter_paragraph_item.dart';

class BibleChapterBody extends StatelessWidget {
  final Book book;
  final int chapter;
  final List<String> paragraphs;
  final int? selectedParaIndex;
  final Set<int>? selectedParas;
  final List<GlobalKey>? paraKeys;
  final ValueChanged<int>? onParagraphLongPress;
  final ValueChanged<int> onParagraphTap;
  final VoidCallback? onAddPressed;
  final bool isDarkMode;

  const BibleChapterBody({
    super.key,
    required this.book,
    required this.chapter,
    required this.paragraphs,
    required this.selectedParaIndex,
    this.selectedParas,
    required this.paraKeys,
    this.onParagraphLongPress,
    required this.onParagraphTap,
    this.onAddPressed,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDarkMode ? Colors.white : Color(0xFF21252C);

    final chapterTitle = BibleChapterStateController.chapterTitle(
      bookId: book.id,
      chapter: chapter,
    );

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            chapterTitle ?? 'Chapter $chapter',
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12),
          ListView.separated(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: paragraphs.length,
            separatorBuilder: (_, __) => SizedBox(height: 8),
            itemBuilder: (context, index) {
              final p = paragraphs[index];
              final selected = index == selectedParaIndex;
              final isSelected =
                  selected || (selectedParas?.contains(index) ?? false);
              return BibleChapterParagraphItem(
                book: book,
                chapter: chapter,
                paragraph: p,
                index: index,
                isSelected: isSelected,
                paraKey: paraKeys == null ? null : paraKeys![index],
                onTap: () => onParagraphTap(index),
                onLongPress: onParagraphLongPress == null
                    ? null
                    : () => onParagraphLongPress!(index),
                onAddPressed: isSelected ? onAddPressed : null,
                isDarkMode: isDarkMode,
              );
            },
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }
}
