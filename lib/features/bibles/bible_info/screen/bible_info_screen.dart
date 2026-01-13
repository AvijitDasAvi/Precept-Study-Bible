import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../controller/bible_info_controller.dart';
import '../../all_bibles/controller/all_bibles_controller.dart';
import '../../bible_chapter_page/screen/bible_chapter_page_screen.dart';
import '../../../navbar/widget/advertisement_banner.dart';
import 'package:calvinlockhart/core/utils/localization/localization_service.dart';
import 'package:calvinlockhart/core/utils/constants/api_constants.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import '../../../navbar/controller/navbar_controller.dart';

class BibleInfoScreen extends StatefulWidget {
  final Book book;
  final String? initialVersion;

  const BibleInfoScreen({super.key, required this.book, this.initialVersion});

  @override
  State<BibleInfoScreen> createState() => _BibleInfoScreenState();
}

class _BibleInfoScreenState extends State<BibleInfoScreen> {
  int? _selectedChapter;
  String? _selectedVersion;
  bool _chapterExpanded = false;
  bool _versionExpanded = false;
  bool _hasSpanishData = false;

  @override
  void initState() {
    super.initState();
    _selectedVersion =
        widget.initialVersion ?? BibleInfoController.categoryFor(widget.book);
    _checkSpanishDataAvailability();
  }

  Future<void> _checkSpanishDataAvailability() async {
    try {
      final bookName = widget.book.title.toLowerCase();
      final spanishUrl = ApiConstants.spanishBook.replaceAll(
        '{bookName}',
        bookName,
      );

      debugPrint('🔍 Checking Spanish data availability at: $spanishUrl');

      final response = await http
          .get(Uri.parse(spanishUrl))
          .timeout(const Duration(seconds: 5));

      debugPrint(
        '🔍 Spanish availability check status: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        setState(() {
          _hasSpanishData = true;
        });
        debugPrint('✅ Spanish data available for ${widget.book.title}');
      } else {
        setState(() {
          _hasSpanishData = false;
        });
        debugPrint('❌ Spanish data not available (${response.statusCode})');
      }
    } catch (e) {
      debugPrint('❌ Error checking Spanish availability: $e');
      setState(() {
        _hasSpanishData = false;
      });
    }
  }

  Widget _buildAppBarIcon(IconData icon, VoidCallback onTap, bool isDarkMode) {
    final bgColor = isDarkMode ? Colors.grey[800] : Color(0xFFEDEEF0);
    final iconColor = isDarkMode ? Colors.white : Color(0xFF21252C);

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: SizedBox(
          width: 50,
          height: 50,
          child: Center(child: Icon(icon, color: iconColor, size: 20)),
        ),
      ),
    );
  }

  void _onNext() {
    if (_selectedChapter == null) {
      EasyLoading.showInfo(
        LocalizationService.translate('please_select_chapter'),
      );
      return;
    }

    // If Spanish is selected, we'll pass it as the version
    // The bible_chapter_page_screen will need to handle fetching Spanish verses
    final selectedVersion =
        _selectedVersion ?? BibleInfoController.categoryFor(widget.book);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BibleChapterPageScreen(
          book: widget.book,
          chapter: _selectedChapter!,
          version: selectedVersion,
          hasSpanishData: _hasSpanishData,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDarkMode ? Colors.black : Colors.white;
    final appBarBgColor = isDarkMode ? Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Color(0xFF21252C);
    final secondaryTextColor = isDarkMode
        ? Colors.grey[400]
        : Color(0xFF383E4B);
    final tertiaryTextColor = isDarkMode ? Colors.grey[500] : Color(0xFF727987);
    final containerBgColor = isDarkMode ? Colors.grey[850] : Color(0xFFEDEEF0);
    final placeholderBgColor = isDarkMode
        ? Colors.grey[800]
        : Colors.grey.shade200;
    const primaryBlue = Color(0xFF00228E);

    final chapters = BibleInfoController.chaptersFor(widget.book);
    final versions = BibleInfoController.availableVersions();

    // Add Spanish if available
    final allVersions = [...versions];
    if (_hasSpanishData && !allVersions.contains('Spanish')) {
      allVersions.add('Spanish');
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: appBarBgColor,
        elevation: 0,
        leading: Padding(
          padding: EdgeInsets.only(left: 12),
          child: _buildAppBarIcon(
            Icons.arrow_back_ios_new,
            () => Navigator.maybePop(context),
            isDarkMode,
          ),
        ),
        centerTitle: true,
        title: Text(
          LocalizationService.translate('bible_title'),
          style: TextStyle(
            color: textColor,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: _buildAppBarIcon(Icons.home, () {
              try {
                Get.offAllNamed('/navbar');
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  try {
                    final navController = Get.find<NavbarController>();
                    navController.changeIndex(0);
                  } catch (_) {}
                });
              } catch (_) {
                Navigator.maybePop(context);
              }
            }, isDarkMode),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child:
                            (widget.book.coverUrl != null &&
                                widget.book.coverUrl!.trim().isNotEmpty)
                            ? Image.network(
                                widget.book.coverUrl!,
                                width: 149,
                                height: 200,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 149,
                                  height: 200,
                                  color: placeholderBgColor,
                                  child: Center(
                                    child: Icon(
                                      Icons.book,
                                      color: isDarkMode
                                          ? Colors.grey[700]
                                          : Colors.grey.shade400,
                                      size: 48,
                                    ),
                                  ),
                                ),
                              )
                            : Container(
                                width: 149,
                                height: 200,
                                color: placeholderBgColor,
                                child: Center(
                                  child: Icon(
                                    Icons.book,
                                    color: isDarkMode
                                        ? Colors.grey[700]
                                        : Colors.grey.shade400,
                                    size: 48,
                                  ),
                                ),
                              ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.book.title,
                              style: TextStyle(
                                color: textColor,
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              widget.book.author,
                              style: TextStyle(
                                color: secondaryTextColor,
                                fontSize: 13,
                              ),
                            ),
                            SizedBox(height: 12),
                            Text(
                              LocalizationService.translate(
                                'chapters_count',
                              ).replaceAll(
                                '{count}',
                                widget.book.chapters.toString(),
                              ),
                              style: TextStyle(color: tertiaryTextColor),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  GestureDetector(
                    onTap: () => setState(() {
                      _chapterExpanded = !_chapterExpanded;
                      if (_chapterExpanded) _versionExpanded = false;
                    }),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: containerBgColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _selectedChapter == null
                                  ? LocalizationService.translate(
                                      'select_chapter',
                                    )
                                  : LocalizationService.translate(
                                      'chapter_label',
                                    ).replaceAll(
                                      '{num}',
                                      _selectedChapter.toString(),
                                    ),
                              style: TextStyle(color: secondaryTextColor),
                            ),
                          ),
                          Icon(
                            _chapterExpanded
                                ? Icons.arrow_drop_up
                                : Icons.arrow_drop_down,
                            color: secondaryTextColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  if (_chapterExpanded)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: containerBgColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: chapters.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 6,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 1,
                        ),
                        itemBuilder: (context, index) {
                          final c = chapters[index];
                          final selected = c == _selectedChapter;
                          return Material(
                            color: selected
                                ? primaryBlue
                                : (isDarkMode
                                      ? Colors.grey[800]
                                      : Colors.white),
                            borderRadius: BorderRadius.circular(8),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedChapter = c;
                                  _chapterExpanded = false;
                                });
                              },
                              child: Center(
                                child: Text(
                                  '$c',
                                  style: TextStyle(
                                    color: selected ? Colors.white : textColor,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  if (_chapterExpanded) SizedBox(height: 12),

                  GestureDetector(
                    onTap: () => setState(() {
                      _versionExpanded = !_versionExpanded;
                      if (_versionExpanded) _chapterExpanded = false;
                    }),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: containerBgColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _selectedVersion ?? 'Version',
                              style: TextStyle(color: secondaryTextColor),
                            ),
                          ),
                          Icon(
                            _versionExpanded
                                ? Icons.arrow_drop_up
                                : Icons.arrow_drop_down,
                            color: secondaryTextColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  if (_versionExpanded)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: containerBgColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Wrap(
                        spacing: 9,
                        runSpacing: 9,
                        children: allVersions.map((v) {
                          final selected = v == _selectedVersion;
                          return Material(
                            color: selected
                                ? primaryBlue
                                : (isDarkMode
                                      ? Colors.grey[800]
                                      : Colors.white),
                            borderRadius: BorderRadius.circular(6),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(6),
                              onTap: () {
                                setState(() {
                                  _selectedVersion = v;
                                  _versionExpanded = false;
                                });
                              },
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                child: Text(
                                  v,
                                  style: TextStyle(
                                    color: selected ? Colors.white : textColor,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: _onNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        padding: EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        LocalizationService.translate('next'),
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(20),
            child: AdvertisementBanner(horizontalPadding: 0, onTap: () {}),
          ),
        ],
      ),
    );
  }
}
