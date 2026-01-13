import 'package:calvinlockhart/core/services/network_caller.dart';
import 'package:calvinlockhart/core/utils/constants/api_constants.dart';
import 'package:flutter/foundation.dart';

class Book {
  final String id;
  final String title;
  final String author;
  final int chapters;
  final String? coverUrl;
  final String? uiVersion;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.chapters,
    this.coverUrl,
    this.uiVersion,
  });
}

class AllBiblesController {
  static Map<String, List<Book>> categories = {
    'Recommended Books': [],
    'KJV': [],
    'KJVA': [],
    'KJV+': [],
  };

  static Future<Map<String, List<Book>>> fetchRecommendedBooks(
    NetworkCaller caller,
  ) async {
    try {
      debugPrint(
        '🔍 Fetching recommended books from ${ApiConstants.recommendedBooks}',
      );
      final res = await caller.getRequest(ApiConstants.recommendedBooks);
      final raw = res.responseData;
      if (raw == null) {
        debugPrint(
          '🔍 Empty response for recommended books. Status: ${res.statusCode}',
        );
        return {'recommended': <Book>[]};
      }

      final data = (raw is Map) ? (raw['data'] ?? raw) : raw;
      if (data is! Map) {
        debugPrint('🔍 Recommended books response is not a map');
        return {'recommended': <Book>[]};
      }

      final result = <String, List<Book>>{};
      data.forEach((key, value) {
        if (value is List) {
          final list = value.map((item) {
            final translationId = (item['translationId'] ?? key).toString();
            return Book(
              id: (item['id'] ?? '').toString(),
              title: (item['name'] ?? item['commonName'] ?? '').toString(),
              author: (item['author'] ?? '').toString(),
              chapters:
                  int.tryParse((item['numberOfChapters'] ?? 0).toString()) ?? 0,
              coverUrl: (item['coverImage'] ?? '').toString().isEmpty
                  ? null
                  : (item['coverImage'] ?? '').toString(),
              uiVersion: translationId.isEmpty
                  ? null
                  : _mapTranslationIdToSection(translationId),
            );
          }).toList();
          result[key.toString()] = List<Book>.from(list);
        }
      });

      final recommended = <Book>[];
      for (final l in result.values) {
        recommended.addAll(l);
      }
      if (recommended.isNotEmpty) result['recommended'] = recommended;

      return result;
    } catch (e) {
      debugPrint('🔍 Error fetching recommended books: $e');
      return {'recommended': <Book>[]};
    }
  }

  static String _mapTranslationIdToSection(String translationId) {
    if (translationId.contains('kjv')) return 'KJV';
    if (translationId.contains('kja')) return 'KJVA';
    if (translationId.contains('cpb')) return 'KJV+';
    return 'KJV';
  }
}
