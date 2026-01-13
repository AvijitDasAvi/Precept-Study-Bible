import 'package:calvinlockhart/core/services/network_caller.dart';
import 'package:calvinlockhart/core/utils/constants/api_constants.dart';
import 'package:flutter/foundation.dart';

class BibleService {
  static Future<List<Map<String, dynamic>>> fetchBibleBooks(
    NetworkCaller caller,
  ) async {
    try {
      debugPrint('🔍 Fetching Bible books from ${ApiConstants.kjva}');
      final res = await caller.getRequest(ApiConstants.kjva);
      if (!res.isSuccess) {
        debugPrint('🔍 Failed to fetch Bible books. Status: ${res.statusCode}');
        return [];
      }

      final data = res.responseData['data'] ?? res.responseData;
      if (data is! List) {
        debugPrint('🔍 Bible books data is not a list: ${data.runtimeType}');
        return [];
      }

      final books = data.map((item) {
        return {
          'id': (item['id'] ?? '').toString(),
          'name': (item['name'] ?? item['commonName'] ?? '').toString(),
          'chapters':
              int.tryParse((item['numberOfChapters'] ?? 0).toString()) ?? 0,
        };
      }).toList();

      debugPrint('🔍 Processed ${books.length} Bible books');
      return List<Map<String, dynamic>>.from(books);
    } catch (e) {
      debugPrint('🔍 Error fetching Bible books: $e');
      return [];
    }
  }

  static List<int> parseVerses(String versesPart) {
    final verses = <int>[];
    final parts = versesPart.split(',');

    for (final part in parts) {
      final trimmed = part.trim();
      if (trimmed.contains('-')) {
        final range = trimmed.split('-');
        if (range.length == 2) {
          final start = int.tryParse(range[0].trim()) ?? 0;
          final end = int.tryParse(range[1].trim()) ?? 0;
          if (start > 0 && end > 0 && start <= end) {
            for (int i = start; i <= end; i++) {
              verses.add(i);
            }
          }
        }
      } else {
        final verse = int.tryParse(trimmed) ?? 0;
        if (verse > 0) verses.add(verse);
      }
    }

    final unique = verses.toSet().toList()..sort();
    return unique;
  }

  static Future<String?> fetchVersesCombinedText(
    NetworkCaller caller,
    String bookName,
    int chapter,
    String versesPart,
  ) async {
    try {
      final verseNumbers = parseVerses(versesPart);
      if (verseNumbers.isEmpty) return null;

      final books = await fetchBibleBooks(caller);
      Map<String, dynamic>? book;

      // Normalize the book name: handle numeric prefixes like "1", "2", "3"
      String normalizedInput = bookName.toLowerCase();

      try {
        book = books.firstWhere((b) {
          String normalizedBook = b['name'].toString().toLowerCase();

          // Direct match
          if (normalizedBook == normalizedInput) return true;

          // Handle numeric prefixes: "1 Kings" -> "I Kings", "2 Corinthians" -> "II Corinthians"
          final numericMatch = RegExp(
            r'^(\d+)\s+(.+)$',
          ).firstMatch(normalizedInput);
          if (numericMatch != null) {
            final number = numericMatch.group(1)!;
            final rest = numericMatch.group(2)!.trim();
            final romanNumeral = _arabicToRoman(int.parse(number));
            final romanForm = '$romanNumeral $rest';
            if (normalizedBook == romanForm) return true;
            // Also try with the number word
            final numberWords = ['first', 'second', 'third'];
            if (int.parse(number) <= numberWords.length) {
              final numberWord = numberWords[int.parse(number) - 1];
              if (normalizedBook == '$numberWord $rest') return true;
            }
          }

          return false;
        });
      } catch (e) {
        book = null;
      }

      if (book == null) return null;
      final bookId = book['id'].toString();
      final url = '${ApiConstants.kjva}/$bookId/$chapter';
      debugPrint('🔍 Fetching chapter from URL: $url');

      final resp = await caller.getRequest(url);
      if (!resp.isSuccess) return null;

      final chapterData = resp.responseData;
      final data = (chapterData is Map)
          ? (chapterData['data'] ?? chapterData)
          : chapterData;
      final chapterNode = (data is Map) ? (data['chapter'] ?? data) : data;
      final content = chapterNode['content'];
      if (content == null || content is! List) return null;

      final List<String> verseTexts = [];
      int currentVerse = 1;

      for (final item in content) {
        if (item is Map && item['content'] != null) {
          if (verseNumbers.contains(currentVerse)) {
            final inner = item['content'];
            if (inner is List) {
              final parts = inner
                  .map((p) {
                    if (p is String) return p;
                    if (p is Map && p.containsKey('text')) {
                      return p['text'].toString();
                    }
                    return '';
                  })
                  .where((s) => s.trim().isNotEmpty)
                  .toList();
              final verseText = parts.join(' ');
              if (verseText.isNotEmpty) {
                verseTexts.add('$bookName $chapter:$currentVerse - $verseText');
              }
            }
          }
          currentVerse++;
          if (verseTexts.length >= verseNumbers.length) break;
        }
      }

      if (verseTexts.isNotEmpty) return verseTexts.join('\n\n');
      return null;
    } catch (e) {
      debugPrint('🔍 Error in fetchVersesCombinedText: $e');
      return null;
    }
  }

  static String _arabicToRoman(int number) {
    switch (number) {
      case 1:
        return 'I';
      case 2:
        return 'II';
      case 3:
        return 'III';
      default:
        return number.toString();
    }
  }
}
