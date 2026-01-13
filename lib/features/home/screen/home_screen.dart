import 'package:calvinlockhart/features/appbar/screen/custom_appbar_screen.dart';
import '../../navbar/widget/advertisement_banner.dart';
import '../../../core/services/network_caller.dart';
import '../../../core/utils/constants/api_constants.dart';
import 'package:flutter/material.dart';
import '../../../core/utils/constants/colors.dart';
import '../widget/add_topic_dialog.dart';
import 'package:calvinlockhart/core/utils/localization/localization_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _preceptLabel;
  String? _preceptBookId;
  int? _preceptChapter;
  int? _preceptVerse;
  String? _preceptContent;

  @override
  void initState() {
    super.initState();
    _loadPreceptOfTheDay();
  }

  Future<void> _loadPreceptOfTheDay() async {
    try {
      final caller = NetworkCaller();
      final res = await caller.getRequest(ApiConstants.preceptOfTheDay);
      if (!res.isSuccess) return;

      final data = res.responseData is Map
          ? (res.responseData['data'] ?? res.responseData)
          : res.responseData;

      if (data is Map) {
        final bookName = data['bookName']?.toString();
        final chapterNumber = (data['chapterNumber'] is int)
            ? data['chapterNumber'] as int
            : int.tryParse(data['chapterNumber']?.toString() ?? '0');
        final verseNumber = (data['verseNumber'] is int)
            ? data['verseNumber'] as int
            : int.tryParse(data['verseNumber']?.toString() ?? '0');
        final content = data['content']?.toString();

        if (bookName != null && chapterNumber != null && verseNumber != null) {
          setState(() {
            _preceptBookId = bookName;
            _preceptChapter = chapterNumber;
            _preceptVerse = verseNumber;
            _preceptLabel =
                '${bookName.toUpperCase()} $chapterNumber : $verseNumber';
            _preceptContent = content;
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading precept of the day: $e');
    }
  }

  void _openCreateTopicWithPrecept(BuildContext context) {
    final preceptText =
        (_preceptBookId != null &&
            _preceptChapter != null &&
            _preceptVerse != null)
        ? _preceptLabel ?? ''
        : '';

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Color(0xFFF8FAFF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: AddTopicDialog(
          initialTopicName: null,
          initialPreceptTitle: preceptText,
          initialPreceptContent: _preceptContent,
        ),
      ),
    );
  }

  void _openCreateTopicEmpty(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Color(0xFFF8FAFF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: AddTopicDialog(
          initialTopicName: null,
          initialPreceptTitle: '',
          initialPreceptContent: '',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDarkMode ? Colors.black : Colors.white;
    final containerBgColor = isDarkMode ? Colors.grey[850] : Color(0xFFE6E9F4);
    final preceptLabelColor = isDarkMode ? Colors.white : Color(0xFF21252C);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: CustomAppBar(
        // onSearchTap: () => Navigator.of(
        //   context,
        // ).push(MaterialPageRoute(builder: (_) => SearchScreen())),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 24),
                  Text(
                    LocalizationService.translate('precept_of_the_day'),
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 12),
                  GestureDetector(
                    onTap: _preceptLabel == null
                        ? null
                        : () => _openCreateTopicWithPrecept(context),
                    child: Text(
                      _preceptLabel ?? '...loading',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: preceptLabelColor,
                      ),
                    ),
                  ),
                  SizedBox(height: 28),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: GestureDetector(
                      onTap: () => _openCreateTopicEmpty(context),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: containerBgColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.add, color: AppColors.primary),
                            SizedBox(width: 8),
                            Text(
                              LocalizationService.translate('create_topic'),
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
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
