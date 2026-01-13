import 'dart:async';
import 'package:flutter/material.dart';
import '../../all_bibles/screen/all_bibles_screen.dart';
import '../../../navbar/widget/advertisement_banner.dart';

import '../controller/bible_search_controller.dart';
import '../../all_bibles/controller/all_bibles_controller.dart';
import '../../bible_info/screen/bible_info_screen.dart';

class BibleSearchScreen extends StatefulWidget {
  const BibleSearchScreen({super.key});

  @override
  State<BibleSearchScreen> createState() => _BibleSearchScreenState();
}

class _BibleSearchScreenState extends State<BibleSearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<Map<String, dynamic>> _results = [];
  Timer? _debounce;

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(Duration(milliseconds: 250), () async {
      final q = _controller.text;
      final results = await BibleSearchController.search(q);
      if (!mounted) return;
      setState(() {
        _results = results;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.removeListener(_onSearchChanged);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDarkMode ? Colors.black : Colors.white;
    final appBarBgColor = isDarkMode ? Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Color(0xFF21252C);
    final secondaryTextColor = isDarkMode
        ? Colors.grey[400]
        : Color(0xFF898F9B);
    final searchBoxBgColor = isDarkMode ? Colors.grey[850] : Color(0xFFEDEEF0);
    final backButtonBgColor = isDarkMode ? Colors.grey[800] : Color(0xFFEDEEF0);
    final emptyStateTextColor = isDarkMode
        ? Colors.grey[400]
        : Color(0xFF6B6F76);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: appBarBgColor,
        elevation: 0,
        leading: Padding(
          padding: EdgeInsets.only(left: 12),
          child: Material(
            color: backButtonBgColor,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => Navigator.maybePop(context),
              child: SizedBox(
                width: 36,
                height: 36,
                child: Icon(Icons.arrow_back, color: textColor, size: 20),
              ),
            ),
          ),
        ),
        centerTitle: true,
        title: Text(
          'Search Result',
          style: TextStyle(
            color: textColor,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          children: [
            Container(
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
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Search bible',
                        hintStyle: TextStyle(color: secondaryTextColor),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                      style: TextStyle(color: textColor),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: _results.isEmpty
                  ? Center(
                      child: Text(
                        _controller.text.isEmpty
                            ? 'Type to search bibles'
                            : 'No results for "${_controller.text}"',
                        style: TextStyle(color: emptyStateTextColor),
                      ),
                    )
                  : GridView.builder(
                      itemCount: _results.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.68,
                      ),
                      itemBuilder: (context, index) {
                        final item = _results[index];
                        final Book b = item['book'];
                        final String version = (item['version'] ?? 'KJV')
                            .toString();
                        return GestureDetector(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => BibleInfoScreen(
                                book: b,
                                initialVersion: version,
                              ),
                            ),
                          ),
                          child: BibleCard(book: b, isDarkMode: isDarkMode),
                        );
                      },
                    ),
            ),

            Padding(
              padding: EdgeInsets.only(left: 20, right: 20, bottom: 16),
              child: AdvertisementBanner(horizontalPadding: 20, onTap: () {}),
            ),
          ],
        ),
      ),
    );
  }
}
