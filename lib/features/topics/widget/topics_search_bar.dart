import 'package:flutter/material.dart';
import '../controller/topics_controller.dart';

class TopicsSearchBar extends StatelessWidget {
  final TopicsController controller;
  final bool isDarkMode;

  const TopicsSearchBar({
    super.key,
    required this.controller,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final searchIconColor = isDarkMode ? Colors.grey[400] : Color(0xFF898F9B);
    final searchTextColor = isDarkMode ? Colors.white : Color(0xFF21252C);
    final searchHintColor = isDarkMode ? Colors.grey[500] : Color(0xFF898F9B);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Row(
        children: [
          Icon(Icons.search, size: 24, color: searchIconColor),
          SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller.searchController,
              onChanged: controller.updateSearchQuery,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Search your topic',
                hintStyle: TextStyle(
                  color: searchHintColor,
                  fontSize: 15,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w400,
                  height: 1.50,
                ),
              ),
              style: TextStyle(
                color: searchTextColor,
                fontSize: 15,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w400,
                height: 1.50,
              ),
            ),
          ),
          if (controller.searchQuery.isNotEmpty)
            GestureDetector(
              onTap: controller.clearSearch,
              child: Icon(Icons.clear, size: 20, color: searchIconColor),
            ),
        ],
      ),
    );
  }
}
