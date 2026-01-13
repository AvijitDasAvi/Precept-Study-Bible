import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/network_caller.dart';
import '../../../core/utils/constants/api_constants.dart';
import '../models/topic_models.dart';
import 'package:flutter/material.dart';

class TopicNotesService {
  static Future<List<NoteModel>> loadNotes(String topicId) async {
    try {
      final caller = NetworkCaller();
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token') ?? '';
      final authHeader = token.isNotEmpty ? 'Bearer $token' : '';

      final url = '${ApiConstants.getSingleTopic}/$topicId';
      final res = await caller.getRequest(url, token: authHeader);

      if (res.isSuccess) {
        final data = res.responseData['data'];
        if (data is Map<String, dynamic> && data['notes'] is List) {
          final notesJson = data['notes'] as List;
          final notes = notesJson
              .whereType<Map<String, dynamic>>()
              .map((n) => NoteModel.fromJson(n))
              .toList();

          debugPrint('📝 Loaded ${notes.length} notes for topic ID: $topicId');
          return notes;
        }
      } else {
        debugPrint(
          '❌ Failed to load notes for topic ID: $topicId - ${res.errorMessage}',
        );
      }
    } catch (e) {
      debugPrint('❌ Error loading notes for topic ID: $topicId - $e');
    }
    return [];
  }

  static Future<bool> updateNote(String noteId, String description) async {
    try {
      final caller = NetworkCaller();
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token') ?? '';
      final authHeader = token.isNotEmpty ? 'Bearer $token' : '';

      final requestBody = {'description': description};
      final url = ApiConstants.patchNote.replaceAll('{noteId}', noteId);

      debugPrint('🔄 Updating note - URL: $url');
      debugPrint('🔄 Update body: $requestBody');

      final res = await caller.patchRequest(
        url,
        token: authHeader,
        body: requestBody,
      );

      debugPrint('🔄 Note update response success: ${res.isSuccess}');
      if (!res.isSuccess) {
        debugPrint('🔄 Note update error: ${res.errorMessage}');
      }

      return res.isSuccess;
    } catch (e) {
      debugPrint('❌ Note update exception: $e');
      return false;
    }
  }
}
