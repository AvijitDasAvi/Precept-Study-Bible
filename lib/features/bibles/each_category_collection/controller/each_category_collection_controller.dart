import '../../all_bibles/controller/all_bibles_controller.dart';
import 'package:calvinlockhart/core/services/network_caller.dart';
import 'package:calvinlockhart/core/utils/constants/api_constants.dart';
import 'package:flutter/foundation.dart';

class EachCategoryCollectionController {
  static final NetworkCaller _caller = NetworkCaller();

  static Future<List<Book>> getBooksForCategory(String category) async {
    String? endpoint;
    if (category == 'KJV') endpoint = ApiConstants.kjv;
    if (category == 'KJVA') endpoint = ApiConstants.kjva;
    if (category == 'KJV+') endpoint = ApiConstants.kjvcp;

    if (endpoint != null) {
      try {
        final res = await _caller.getRequest(endpoint);
        if (res.isSuccess && res.responseData != null) {
          final data = res.responseData['data'] ?? res.responseData;
          if (data is List) {
            return data.map((item) {
              final id = (item['id'] ?? '').toString();
              final name = (item['name'] ?? item['commonName'] ?? id)
                  .toString();
              final chapters =
                  int.tryParse((item['numberOfChapters'] ?? 0).toString()) ?? 0;
              final rawCover =
                  item['coverImage']?.toString() ??
                  item['coverUrl']?.toString();
              final cover =
                  (rawCover == null ||
                      rawCover.trim().isEmpty ||
                      rawCover.toLowerCase() == 'null')
                  ? 'https://placehold.co/800x1200'
                  : rawCover;

              return Book(
                id: id,
                title: name,
                author: (item['author'] ?? item['translationId'] ?? '')
                    .toString(),
                chapters: chapters,
                coverUrl: cover,
                uiVersion: (item['translationId'] ?? '').toString().isEmpty
                    ? null
                    : ((item['translationId'] ?? '').toString().contains('kjv')
                          ? 'KJV'
                          : (item['translationId'] ?? '').toString().contains(
                              'kja',
                            )
                          ? 'KJVA'
                          : (item['translationId'] ?? '').toString().contains(
                              'cpb',
                            )
                          ? 'KJV+'
                          : 'KJV'),
              );
            }).toList();
          }
        }
      } catch (e) {
        debugPrint('Error fetching books for $category: $e');
      }
    }

    return <Book>[];
  }
}
