import 'package:flutter/material.dart';

import '../controller/each_category_collection_controller.dart';
import '../../all_bibles/controller/all_bibles_controller.dart';
import '../../all_bibles/screen/all_bibles_screen.dart';
import '../../bible_info/screen/bible_info_screen.dart';
import '../../../navbar/widget/advertisement_banner.dart';
import 'package:calvinlockhart/core/utils/localization/localization_service.dart';

class EachCategoryCollectionScreen extends StatefulWidget {
  final String categoryTitle;

  const EachCategoryCollectionScreen({super.key, required this.categoryTitle});

  @override
  State<EachCategoryCollectionScreen> createState() =>
      _EachCategoryCollectionScreenState();
}

class _EachCategoryCollectionScreenState
    extends State<EachCategoryCollectionScreen> {
  late TextEditingController _searchController;
  List<Book> _allBooks = [];
  List<Book> _filteredBooks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_filterBooks);
    _loadBooks();
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterBooks);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadBooks() async {
    try {
      final books = await EachCategoryCollectionController.getBooksForCategory(
        widget.categoryTitle,
      );
      setState(() {
        _allBooks = books;
        _filteredBooks = books;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterBooks() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        _filteredBooks = _allBooks;
      } else {
        _filteredBooks = _allBooks
            .where(
              (book) =>
                  book.title.toLowerCase().contains(query) ||
                  book.author.toLowerCase().contains(query),
            )
            .toList();
      }
    });
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
          '${widget.categoryTitle} Books',
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () {
                // Focus on search field
                FocusScope.of(context).requestFocus(FocusNode());
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
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: LocalizationService.translate(
                            'search_bible',
                          ),
                          hintStyle: TextStyle(
                            color: secondaryTextColor,
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                        ),
                        style: TextStyle(color: textColor, fontSize: 16),
                      ),
                    ),
                    if (_searchController.text.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          _searchController.clear();
                        },
                        child: Icon(
                          Icons.close,
                          color: secondaryTextColor,
                          size: 20,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _filteredBooks.isEmpty
                  ? Center(
                      child: Text(
                        _searchController.text.isEmpty
                            ? 'No books available'
                            : 'No books found',
                        style: TextStyle(color: secondaryTextColor),
                      ),
                    )
                  : GridView.builder(
                      itemCount: _filteredBooks.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 10,
                        childAspectRatio: 1.4,
                      ),
                      itemBuilder: (context, index) {
                        final b = _filteredBooks[index];
                        return GestureDetector(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => BibleInfoScreen(
                                book: b,
                                initialVersion: widget.categoryTitle,
                              ),
                            ),
                          ),
                          child: BibleCard(book: b, isDarkMode: isDarkMode),
                        );
                      },
                    ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 20, right: 20, bottom: 16),
            child: AdvertisementBanner(horizontalPadding: 20, onTap: () {}),
          ),
        ],
      ),
    );
  }
}
