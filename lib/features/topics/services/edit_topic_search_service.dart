import 'package:calvinlockhart/core/services/network_caller.dart';
import 'package:calvinlockhart/core/utils/constants/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class EditTopicSearchService {
  static Future<List<Map<String, dynamic>>> searchTopics(
    String query,
    NetworkCaller caller,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token') ?? '';
      final authHeader = token.isNotEmpty ? 'Bearer $token' : '';

      final res = await caller.getRequest(
        '${ApiConstants.getTopics}?search=$query',
        token: authHeader,
      );

      if (res.isSuccess && res.responseData != null) {
        final List<dynamic> data = res.responseData!['data'] ?? [];
        return data.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      debugPrint('Error searching topics: $e');
    }
    return [];
  }
}
