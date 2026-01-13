import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/utils/constants/colors.dart';
import '../../../core/utils/constants/icon_path.dart';
import '../../navbar/widget/advertisement_banner.dart';
import 'package:calvinlockhart/core/utils/localization/localization_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  int? _selectedOptionIndex;
  final TextEditingController _searchController = TextEditingController();

  List<String> get _options => [
    LocalizationService.translate('option_all_words'),
    LocalizationService.translate('option_any_words'),
    LocalizationService.translate('option_phrase'),
    LocalizationService.translate('option_bible'),
    LocalizationService.translate('option_dan'),
    LocalizationService.translate('option_new_testament'),
    LocalizationService.translate('option_old_testament'),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(top: 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8),
                      Container(
                        width: 34,
                        height: 34,
                        padding: EdgeInsets.all(4),
                        decoration: ShapeDecoration(
                          color: Color(0xFFEDEEF0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: Center(
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).maybePop(),
                            child: Icon(
                              Icons.arrow_back,
                              size: 26,
                              color: Color(0xFF2B303A),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 24),

                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: ShapeDecoration(
                          color: Color(0xFFEDEEF0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              IconPath.searchIcon,
                              width: 24,
                              height: 24,
                              color: Color(0xFF898F9B),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                decoration: InputDecoration(
                                  hintText: LocalizationService.translate(
                                    'search_hint',
                                  ),
                                  hintStyle: TextStyle(
                                    color: Color(0xFF898F9B),
                                    fontSize: 15,
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w400,
                                    height: 1.5,
                                  ),
                                  border: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                  isCollapsed: true,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 20),

                      Text(
                        LocalizationService.translate('bible_search_label'),
                        style: TextStyle(
                          color: Color(0xFF21252C),
                          fontSize: 16,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w500,
                          height: 1.5,
                        ),
                      ),

                      SizedBox(height: 12),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(_options.length, (index) {
                          final option = _options[index];
                          final bool selected = _selectedOptionIndex == index;
                          return GestureDetector(
                            onTap: () =>
                                setState(() => _selectedOptionIndex = index),
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  Container(
                                    width: 16,
                                    height: 16,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: selected
                                            ? AppColors.primary
                                            : Color(0xFF2B303A),
                                        width: selected ? 8 : 1.2,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    option,
                                    style: TextStyle(
                                      color: selected
                                          ? AppColors.primary
                                          : Color(0xFF2B303A),
                                      fontSize: 15,
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.w400,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),

                      SizedBox(height: 120),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.only(left: 20, right: 20, bottom: 16),
                child: AdvertisementBanner(horizontalPadding: 20, onTap: () {}),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
