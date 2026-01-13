import 'dart:async';
import 'package:calvinlockhart/core/services/network_caller.dart';
import 'package:calvinlockhart/core/utils/constants/api_constants.dart';
import 'package:flutter/material.dart';
import '../widget/precept_controllers.dart';

class EditTopicBibleService {
  static Future<void> fetchBibleBooks(
    String query,
    PreceptControllers controllers,
    NetworkCaller caller,
    VoidCallback onStateUpdate,
  ) async {
    try {
      final res = await caller.getRequest('${ApiConstants.kjv}/books');
      if (res.isSuccess && res.responseData != null) {
        final List<dynamic> books = res.responseData!['data'] ?? [];
        final filteredBooks = books
            .where(
              (book) => book['name'].toString().toLowerCase().contains(
                query.toLowerCase(),
              ),
            )
            .toList();

        controllers.titleSuggestions = filteredBooks
            .cast<Map<String, dynamic>>();
        onStateUpdate();

        // Check for verse pattern and auto-populate
        _checkAndPopulateVerse(query, controllers, caller, onStateUpdate);
      }
    } catch (e) {
      debugPrint('Error fetching Bible books: $e');
    }
  }

  static void _checkAndPopulateVerse(
    String query,
    PreceptControllers controllers,
    NetworkCaller caller,
    VoidCallback onStateUpdate,
  ) {
    final versePattern = RegExp(
      r'^([A-Za-z\s]+)\s+(\d+):(\d+)(?:[-,]\s*(\d+))*(?:\s*,\s*(\d+)(?:[-,]\s*(\d+))*)*$',
      caseSensitive: false,
    );

    final match = versePattern.firstMatch(query);
    if (match != null) {
      final bookName = match.group(1)?.trim();
      final chapter = match.group(2);
      final verses = _parseVerseReferences(query);

      _fetchVerseContent(
        bookName!,
        chapter!,
        verses,
        controllers,
        caller,
        onStateUpdate,
      );
    }
  }

  static List<int> _parseVerseReferences(String reference) {
    final parts = reference.split(':');
    if (parts.length < 2) return [];
    final versePart = parts[1].trim();
    final verses = <int>[];
    final groups = versePart.split(',');
    for (final group in groups) {
      final trimmedGroup = group.trim();
      if (trimmedGroup.contains('-')) {
        final rangeParts = trimmedGroup.split('-');
        if (rangeParts.length == 2) {
          final start = int.tryParse(rangeParts[0].trim());
          final end = int.tryParse(rangeParts[1].trim());
          if (start != null && end != null) {
            for (int i = start; i <= end; i++) {
              verses.add(i);
            }
          }
        }
      } else {
        final verse = int.tryParse(trimmedGroup);
        if (verse != null) {
          verses.add(verse);
        }
      }
    }
    return verses;
  }

  static Future<void> _fetchVerseContent(
    String bookName,
    String chapter,
    List<int> verses,
    PreceptControllers controllers,
    NetworkCaller caller,
    VoidCallback onStateUpdate,
  ) async {
    if (verses.isEmpty) return;

    try {
      final combinedContent = <String>[];

      for (final verse in verses) {
        final res = await caller.getRequest(
          '${ApiConstants.kjv}/books/$bookName/chapters/$chapter/verses/$verse',
        );

        if (res.isSuccess && res.responseData != null) {
          final verseData = res.responseData!['data'];
          if (verseData != null) {
            final content = verseData['text'] ?? '';
            combinedContent.add(content);
          }
        }
      }

      if (combinedContent.isNotEmpty) {
        controllers.description.text = combinedContent.join(' ');
        onStateUpdate();
      }
    } catch (e) {
      debugPrint('Error fetching verse content: $e');
    }
  }
}
