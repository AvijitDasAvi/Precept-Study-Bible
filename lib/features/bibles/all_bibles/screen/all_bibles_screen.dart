import 'package:flutter/material.dart';

import '../controller/all_bibles_controller.dart';
import '../../each_category_collection/controller/each_category_collection_controller.dart';
import '../../each_category_collection/screen/each_category_collection_screen.dart';
import '../../bible_search/screen/bible_search_screen.dart';
import '../../bible_info/screen/bible_info_screen.dart';
import '../../bible_info/controller/bible_info_controller.dart';
import '../../../navbar/widget/advertisement_banner.dart';
import 'package:calvinlockhart/core/utils/localization/localization_service.dart';
import 'package:calvinlockhart/core/services/network_caller.dart';

class AllBiblesScreen extends StatelessWidget {
  const AllBiblesScreen({super.key});

  final List<String> _sections = const [
    'Recommended Books',
    'KJV',
    'KJVA',
    'KJV+',
  ];

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDarkMode ? Colors.black : Colors.white;
    final textColor = isDarkMode ? Colors.white : Color(0xFF21252C);
    final secondaryTextColor = isDarkMode
        ? Colors.grey[400]
        : Color(0xFF898F9B);
    final searchBoxBgColor = isDarkMode ? Colors.grey[850] : Color(0xFFEDEEF0);
    const primaryColor = Color(0xFF00228E);

    final networkCaller = NetworkCaller();

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Center(
                      child: Text(
                        LocalizationService.translate('bibles_title'),
                        style: TextStyle(
                          color: textColor,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => BibleSearchScreen()),
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: searchBoxBgColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: secondaryTextColor),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          LocalizationService.translate('search_bible'),
                          style: TextStyle(
                            color: secondaryTextColor,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(top: 12, bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _sections.map((title) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 20, left: 20, right: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                title,
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (title != 'Recommended Books')
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            EachCategoryCollectionScreen(
                                              categoryTitle: title,
                                            ),
                                      ),
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size(50, 24),
                                  ),
                                  child: Text(
                                    LocalizationService.translate('see_all'),
                                    style: TextStyle(
                                      color: primaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: 12),
                          SizedBox(
                            height: 90,
                            child: title == 'Recommended Books'
                                ? FutureBuilder<Map<String, List<Book>>>(
                                    future:
                                        AllBiblesController.fetchRecommendedBooks(
                                          networkCaller,
                                        ),
                                    builder: (context, snap) {
                                      if (snap.connectionState ==
                                          ConnectionState.waiting) {
                                        return Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      }
                                      if (snap.hasError) {
                                        return Center(
                                          child: Text(
                                            'Error',
                                            style: TextStyle(color: textColor),
                                          ),
                                        );
                                      }
                                      final data = snap.data ?? {};
                                      final remoteBooks =
                                          data['recommended'] ?? <Book>[];
                                      if (remoteBooks.isEmpty) {
                                        return Center(
                                          child: Text(
                                            'No books',
                                            style: TextStyle(color: textColor),
                                          ),
                                        );
                                      }
                                      return ListView.separated(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: remoteBooks.length,
                                        separatorBuilder: (_, __) =>
                                            SizedBox(width: 12),
                                        itemBuilder: (context, index) {
                                          final b = remoteBooks[index];
                                          return GestureDetector(
                                            onTap: () {
                                              final initial =
                                                  b.uiVersion ??
                                                  BibleInfoController.categoryFor(
                                                    b,
                                                  );
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      BibleInfoScreen(
                                                        book: b,
                                                        initialVersion: initial,
                                                      ),
                                                ),
                                              );
                                            },
                                            child: BibleCard(
                                              book: b,
                                              isDarkMode: isDarkMode,
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  )
                                : FutureBuilder<List<Book>>(
                                    future:
                                        EachCategoryCollectionController.getBooksForCategory(
                                          title,
                                        ),
                                    builder: (context, snap) {
                                      if (snap.connectionState ==
                                          ConnectionState.waiting) {
                                        return Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      }
                                      if (snap.hasError) {
                                        return Center(
                                          child: Text(
                                            'Error',
                                            style: TextStyle(color: textColor),
                                          ),
                                        );
                                      }
                                      final remoteBooks = snap.data ?? <Book>[];
                                      if (remoteBooks.isEmpty) {
                                        return Center(
                                          child: Text(
                                            'No books',
                                            style: TextStyle(color: textColor),
                                          ),
                                        );
                                      }
                                      return ListView.separated(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: remoteBooks.length,
                                        separatorBuilder: (_, __) =>
                                            SizedBox(width: 12),
                                        itemBuilder: (context, index) {
                                          final b = remoteBooks[index];
                                          return GestureDetector(
                                            onTap: () =>
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: (_) =>
                                                        BibleInfoScreen(
                                                          book: b,
                                                          initialVersion: title,
                                                        ),
                                                  ),
                                                ),
                                            child: BibleCard(
                                              book: b,
                                              isDarkMode: isDarkMode,
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: AdvertisementBanner(horizontalPadding: 0, onTap: () {}),
            ),
          ],
        ),
      ),
    );
  }
}

class BibleCard extends StatelessWidget {
  final Book book;
  final bool isDarkMode;

  const BibleCard({super.key, required this.book, required this.isDarkMode});

  Color _getCardBackgroundColor() {
    final version = book.uiVersion?.toUpperCase() ?? '';

    if (version.contains('KJV+')) {
      // Brown shades for KJV+
      return isDarkMode ? Color(0xFF6B4423) : Color(0xFFD4A574);
    } else if (version.contains('KJVA')) {
      // Olive green shades for KJVA
      return isDarkMode ? Color(0xFF556B2F) : Color(0xFF9ACD32);
    } else {
      // Blue shades for KJV (default)
      return isDarkMode ? Color(0xFF1E3A8A) : Color(0xFF87CEEB);
    }
  }

  Color _getTextColor() {
    final bgColor = _getCardBackgroundColor();
    // Return white text for dark backgrounds, dark text for light backgrounds
    final brightness = ThemeData.estimateBrightnessForColor(bgColor);
    return brightness == Brightness.dark ? Colors.white : Colors.black87;
  }

  @override
  Widget build(BuildContext context) {
    final cardBgColor = _getCardBackgroundColor();
    final textColor = _getTextColor();
    final borderColor = isDarkMode ? Colors.grey[800] : Colors.grey.shade300;

    return Container(
      width: 140,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor ?? Colors.grey.shade300),
        color: cardBgColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 8),
          Text(
            book.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: textColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4),
          Text(
            book.author,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: textColor.withValues(alpha: 0.7),
              fontSize: 12,
            ),
          ),
          SizedBox(height: 8),
        ],
      ),
    );
  }
}
