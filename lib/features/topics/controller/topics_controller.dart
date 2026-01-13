import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import '../models/topic_models.dart';
import '../../../core/services/network_caller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../../../core/utils/constants/api_constants.dart';

class TopicsController extends GetxController {
  List<TopicModel> _preceptTopics = [];
  List<TopicModel> _lessonPrecepts = [];
  List<TopicModel> _favorites = [];

  String _searchQuery = '';
  TextEditingController searchController = TextEditingController();

  List<TopicModel> get preceptTopics => _searchQuery.isEmpty
      ? _preceptTopics
      : _filterTopicsByQuery(_preceptTopics);

  List<TopicModel> get lessonPrecepts => _searchQuery.isEmpty
      ? _lessonPrecepts
      : _filterTopicsByQuery(_lessonPrecepts);

  List<TopicModel> get favorites =>
      _searchQuery.isEmpty ? _favorites : _filterTopicsByQuery(_favorites);

  List<TopicModel> _filterTopicsByQuery(List<TopicModel> list) {
    final q = _searchQuery.toLowerCase();
    return list.where((topic) {
      // Search in title
      if (topic.title.toLowerCase().contains(q)) return true;

      // Search in precepts (reference and content)
      for (final p in topic.precepts) {
        if (p.reference.toLowerCase().contains(q)) return true;
        if (p.content.toLowerCase().contains(q)) return true;
        // Search in precept notes
        for (final n in p.notes) {
          if (n.description.toLowerCase().contains(q)) return true;
        }
      }

      return false;
    }).toList();
  }

  String get searchQuery => _searchQuery;

  TopicsController() {
    _fetchTopicsFromApi();
  }

  Future<void> reorderTopics(int oldIndex, int newIndex, TopicType type) async {
    List<TopicModel> topics;
    String prefsKey;

    switch (type) {
      case TopicType.preceptTopics:
        topics = _preceptTopics;
        prefsKey = 'topic_order_precepts';
        break;
      case TopicType.lessonPrecepts:
        topics = _lessonPrecepts;
        prefsKey = 'topic_order_lessons';
        break;
      case TopicType.favorites:
        topics = _favorites;
        prefsKey = 'topic_order_favorites';
        break;
    }

    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final item = topics.removeAt(oldIndex);
    topics.insert(newIndex, item);

    // Save the order to SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      final topicIds = topics.map((t) => t.id).toList();
      await prefs.setStringList(prefsKey, topicIds);
    } catch (e) {
      debugPrint('Failed to save topic order: $e');
    }

    update();
  }

  final NetworkCaller _caller = NetworkCaller();

  Future<void> _fetchTopicsFromApi() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token') ?? '';
      final authHeader = token.isNotEmpty ? 'Bearer $token' : '';

      final res = await _caller.getRequest(
        ApiConstants.getTopics,
        token: authHeader,
      );
      if (!res.isSuccess) return;
      final data = res.responseData['data'];
      if (data is! List) return;

      final List<TopicModel> precepts = [];
      final List<TopicModel> lessons = [];
      final List<TopicModel> favs = [];

      for (final item in data) {
        if (item is Map<String, dynamic>) {
          final destination = (item['destination'] ?? '').toString();

          final id = (item['id'] ?? '').toString();
          final title = item['name'] ?? item['title'] ?? '';
          final createdAt = item['createdAt'] ?? item['createAt'] ?? '';

          final preceptsJson = item['precepts'] as List? ?? [];
          final List<PreceptModel> mappedPrecepts = [];
          for (final p in preceptsJson) {
            if (p is Map<String, dynamic>) {
              final precept = PreceptModel.fromJson(p);
              mappedPrecepts.add(precept);
            }
          }

          final topic = TopicModel(
            id: id,
            title: title.toString(),
            createdAt: createdAt.toString(),
            precepts: mappedPrecepts,
          );

          switch (destination) {
            case 'PRECEPT_TOPIC':
              precepts.add(topic);
              break;
            case 'LESSON_PRECEPTS':
              lessons.add(topic);
              break;
            case 'FAVORITES':
              favs.add(topic);
              break;
            default:
              precepts.add(topic);
          }
        }
      }

      _preceptTopics = precepts;
      _lessonPrecepts = lessons;
      _favorites = favs;

      // Apply saved order
      await _applySavedOrder();

      update();
    } catch (e) {
      debugPrint('Failed to fetch topics: $e');
    }
  }

  Future<void> _applySavedOrder() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Restore precept topics order
      final preceptOrder = prefs.getStringList('topic_order_precepts');
      if (preceptOrder != null) {
        _preceptTopics = _reorderByIds(_preceptTopics, preceptOrder);
      }

      // Restore lesson precepts order
      final lessonOrder = prefs.getStringList('topic_order_lessons');
      if (lessonOrder != null) {
        _lessonPrecepts = _reorderByIds(_lessonPrecepts, lessonOrder);
      }

      // Restore favorites order
      final favoritesOrder = prefs.getStringList('topic_order_favorites');
      if (favoritesOrder != null) {
        _favorites = _reorderByIds(_favorites, favoritesOrder);
      }
    } catch (e) {
      debugPrint('Failed to apply saved order: $e');
    }
  }

  List<TopicModel> _reorderByIds(
    List<TopicModel> topics,
    List<String> orderedIds,
  ) {
    final Map<String, TopicModel> topicMap = {
      for (var topic in topics) topic.id: topic,
    };

    final reordered = <TopicModel>[];

    // Add topics in the saved order
    for (final id in orderedIds) {
      if (topicMap.containsKey(id)) {
        reordered.add(topicMap[id]!);
        topicMap.remove(id);
      }
    }

    // Add any new topics that weren't in the saved order
    reordered.addAll(topicMap.values);

    return reordered;
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    update();
  }

  void clearSearch() {
    _searchQuery = '';
    searchController.clear();
    update();
  }

  Future<void> refreshTopics() async {
    await _fetchTopicsFromApi();
  }

  void togglePreceptExpansion(
    String topicId,
    String preceptId,
    TopicType type,
  ) {
    List<TopicModel> topics;
    switch (type) {
      case TopicType.preceptTopics:
        topics = _preceptTopics;
        break;
      case TopicType.lessonPrecepts:
        topics = _lessonPrecepts;
        break;
      case TopicType.favorites:
        topics = _favorites;
        break;
    }

    final topicIndex = topics.indexWhere((t) => t.id == topicId);
    if (topicIndex != -1) {
      final preceptIndex = topics[topicIndex].precepts.indexWhere(
        (p) => p.id == preceptId,
      );
      if (preceptIndex != -1) {
        final precept = topics[topicIndex].precepts[preceptIndex];
        topics[topicIndex].precepts[preceptIndex] = precept.copyWith(
          isExpanded: !precept.isExpanded,
        );
        update();
      }
    }
  }

  Future<void> createTopicNote(
    String topicId,
    String description,
    TopicType type,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token') ?? '';
      final authHeader = token.isNotEmpty ? 'Bearer $token' : '';

      final requestBody = {'description': description, 'topicId': topicId};

      final res = await _caller.postRequest(
        ApiConstants.postNote,
        token: authHeader,
        body: requestBody,
      );

      if (res.isSuccess) {
        await _fetchSingleTopic(topicId, type);
      }
    } catch (e) {
      debugPrint('Failed to create note: $e');
    }
  }

  Future<void> createPreceptNote(
    String preceptId,
    String description,
    TopicType type,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token') ?? '';
      final authHeader = token.isNotEmpty ? 'Bearer $token' : '';

      final requestBody = {'description': description, 'preceptId': preceptId};

      final res = await _caller.postRequest(
        ApiConstants.postNote,
        token: authHeader,
        body: requestBody,
      );

      if (res.isSuccess) {
        // Refresh all topics to get the updated precepts with notes
        await _fetchTopicsFromApi();
      }
    } catch (e) {
      debugPrint('Failed to create precept note: $e');
    }
  }

  List<NoteModel> getPreceptNotesFor(String preceptId, TopicType type) {
    List<TopicModel> topics;
    switch (type) {
      case TopicType.preceptTopics:
        topics = _preceptTopics;
        break;
      case TopicType.lessonPrecepts:
        topics = _lessonPrecepts;
        break;
      case TopicType.favorites:
        topics = _favorites;
        break;
    }

    for (final topic in topics) {
      for (final precept in topic.precepts) {
        if (precept.id == preceptId) {
          return precept.notes;
        }
      }
    }
    return [];
  }

  Future<void> deletePreceptNote(
    String noteId,
    TopicType type,
    String preceptId,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token') ?? '';
      final authHeader = token.isNotEmpty ? 'Bearer $token' : '';

      final url = ApiConstants.deleteNote.replaceAll('{noteId}', noteId);
      final res = await _caller.deleteRequest(url, token: authHeader);

      if (res.isSuccess) {
        // Refresh all topics to get the updated precepts with notes
        await _fetchTopicsFromApi();
      }
    } catch (e) {
      debugPrint('Failed to delete precept note: $e');
    }
  }

  Future<void> updateTopicNote(
    String noteId,
    String description,
    TopicType type,
    String topicId,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token') ?? '';
      final authHeader = token.isNotEmpty ? 'Bearer $token' : '';

      final requestBody = {'description': description};

      final url = ApiConstants.patchNote.replaceAll('{noteId}', noteId);
      debugPrint('🔄 Updating note with URL: $url');
      debugPrint('🔄 Request body: $requestBody');
      debugPrint('🔄 Auth header: $authHeader');

      final res = await _caller.patchRequest(
        url,
        token: authHeader,
        body: requestBody,
      );

      debugPrint('🔄 Update note response: ${res.isSuccess}');
      debugPrint('🔄 Response data: ${res.responseData}');
      debugPrint('🔄 Error message: ${res.errorMessage}');

      if (res.isSuccess) {
        debugPrint('✅ Note updated successfully, refreshing topic data');
        await _fetchSingleTopic(topicId, type);
      } else {
        debugPrint('❌ Failed to update note: ${res.errorMessage}');
      }
    } catch (e) {
      debugPrint('❌ Failed to update note with exception: $e');
    }
  }

  Future<void> deleteTopicNote(
    String noteId,
    TopicType type,
    String topicId,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token') ?? '';
      final authHeader = token.isNotEmpty ? 'Bearer $token' : '';

      final url = ApiConstants.deleteNote.replaceAll('{noteId}', noteId);
      final res = await _caller.deleteRequest(url, token: authHeader);

      if (res.isSuccess) {
        await _fetchSingleTopic(topicId, type);
      }
    } catch (e) {
      debugPrint('Failed to delete note: $e');
    }
  }

  Future<void> _fetchSingleTopic(String topicId, TopicType type) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token') ?? '';
      final authHeader = token.isNotEmpty ? 'Bearer $token' : '';

      final url = '${ApiConstants.getSingleTopic}/$topicId';
      final res = await _caller.getRequest(url, token: authHeader);

      if (res.isSuccess) {
        final data = res.responseData['data'];
        if (data is Map<String, dynamic>) {
          final updatedTopic = TopicModel.fromJson(data);

          List<TopicModel> topics;
          switch (type) {
            case TopicType.preceptTopics:
              topics = _preceptTopics;
              break;
            case TopicType.lessonPrecepts:
              topics = _lessonPrecepts;
              break;
            case TopicType.favorites:
              topics = _favorites;
              break;
          }

          final topicIndex = topics.indexWhere((t) => t.id == topicId);
          if (topicIndex != -1) {
            topics[topicIndex] = updatedTopic;
            update();
          }
        }
      }
    } catch (e) {
      debugPrint('Failed to fetch single topic: $e');
    }
  }

  void shareTopic(TopicModel topic, {Rect? sharePositionOrigin}) {
    debugPrint('Sharing topic: ${topic.title}');

    try {
      if (topic.title.isEmpty) {
        EasyLoading.showInfo('Topic has no content to share.');
        return;
      }

      final StringBuffer shareText = StringBuffer();

      shareText.writeln('📖 ${topic.title}');
      shareText.writeln('');

      if (topic.destination != null && topic.destination!.isNotEmpty) {
        String destinationText = topic.destination!;
        switch (topic.destination) {
          case 'PRECEPT_TOPIC':
            destinationText = 'Precept Topic';
            break;
          case 'LESSON_PRECEPTS':
            destinationText = 'Lesson Precepts';
            break;
          case 'FAVORITES':
            destinationText = 'Favorites';
            break;
        }
        shareText.writeln('📂 Category: $destinationText');
        shareText.writeln('');
      }

      if (topic.precepts.isNotEmpty) {
        shareText.writeln('📝 Precepts (${topic.precepts.length}):');
        shareText.writeln('');

        for (int i = 0; i < topic.precepts.length; i++) {
          final precept = topic.precepts[i];
          shareText.writeln('${i + 1}. ${precept.reference}');
          if (precept.content.isNotEmpty) {
            shareText.writeln('   "${precept.content}"');
          }
          shareText.writeln('');
        }
      }

      if (topic.createdAt.isNotEmpty) {
        shareText.writeln('📅 Created: ${_formatDate(topic.createdAt)}');
        shareText.writeln('');
      }

      shareText.writeln('---');
      shareText.writeln('📱 Shared from Calvin Lockhart App');

      SharePlus.instance.share(
        ShareParams(
          text: shareText.toString(),
          sharePositionOrigin:
              sharePositionOrigin ?? Rect.fromLTWH(0, 0, 100, 100),
        ),
      );

      EasyLoading.showSuccess('Topic shared successfully!');
    } catch (e) {
      debugPrint('Error sharing topic: $e');
      EasyLoading.showError('Failed to share topic. Please try again.');
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.month}/${date.day}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  void downloadTopic(TopicModel topic) {
    debugPrint('Downloading topic: ${topic.title}');
  }

  Future<bool> editTopic(
    String topicId,
    String newTitle,
    String destination,
    List<Map<String, String>> precepts,
    TopicType type,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token') ?? '';
      final authHeader = token.isNotEmpty ? 'Bearer $token' : '';

      final url = ApiConstants.updateTopic.replaceAll('{topicId}', topicId);
      debugPrint('📝 Updating topic with URL: $url');
      debugPrint('📝 New title: $newTitle');
      debugPrint('📝 Destination: $destination');
      debugPrint('📝 Precepts count: ${precepts.length}');

      // Update the topic with name, destination, and precepts using PATCH
      final updateBody = {
        'name': newTitle,
        'destination': destination,
        'precepts': precepts,
      };

      debugPrint('📝 Request body: $updateBody');

      final updateRes = await _caller.patchRequest(
        url,
        body: updateBody,
        token: authHeader,
      );

      debugPrint('📝 Update topic response success: ${updateRes.isSuccess}');
      if (!updateRes.isSuccess) {
        debugPrint('📝 Update topic error: ${updateRes.errorMessage}');
        return false;
      }

      // Update the topic in the local state
      if (updateRes.responseData != null &&
          updateRes.responseData!['data'] != null) {
        final updatedTopic = TopicModel.fromJson(updateRes.responseData!['data']);

        switch (type) {
          case TopicType.preceptTopics:
            final index = _preceptTopics.indexWhere((t) => t.id == topicId);
            if (index != -1) {
              _preceptTopics[index] = updatedTopic;
            }
            break;
          case TopicType.lessonPrecepts:
            final index = _lessonPrecepts.indexWhere((t) => t.id == topicId);
            if (index != -1) {
              _lessonPrecepts[index] = updatedTopic;
            }
            break;
          case TopicType.favorites:
            final index = _favorites.indexWhere((t) => t.id == topicId);
            if (index != -1) {
              _favorites[index] = updatedTopic;
            }
            break;
        }
      }

      update();
      debugPrint('📝 Topic updated successfully in local state');
      return true;
    } catch (e) {
      debugPrint('📝 Error updating topic: $e');
      return false;
    }
  }

  Future<void> deleteTopic(String topicId, TopicType type) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token') ?? '';
      final authHeader = token.isNotEmpty ? 'Bearer $token' : '';

      final url = ApiConstants.deleteTopic.replaceAll('{topicId}', topicId);
      debugPrint('🗑️ Deleting topic with URL: $url');

      final res = await _caller.deleteRequest(url, token: authHeader);

      debugPrint('🗑️ Delete topic response success: ${res.isSuccess}');
      if (!res.isSuccess) {
        debugPrint('🗑️ Delete topic error: ${res.errorMessage}');
        return;
      }

      switch (type) {
        case TopicType.preceptTopics:
          _preceptTopics.removeWhere((t) => t.id == topicId);
          break;
        case TopicType.lessonPrecepts:
          _lessonPrecepts.removeWhere((t) => t.id == topicId);
          break;
        case TopicType.favorites:
          _favorites.removeWhere((t) => t.id == topicId);
          break;
      }
      update();
      debugPrint('✅ Topic deleted successfully');
    } catch (e) {
      debugPrint('❌ Failed to delete topic: $e');
    }
  }

  void addPrecept(String topicId, PreceptModel precept, TopicType type) {
    List<TopicModel> topics;
    switch (type) {
      case TopicType.preceptTopics:
        topics = _preceptTopics;
        break;
      case TopicType.lessonPrecepts:
        topics = _lessonPrecepts;
        break;
      case TopicType.favorites:
        topics = _favorites;
        break;
    }

    final topicIndex = topics.indexWhere((t) => t.id == topicId);
    if (topicIndex != -1) {
      topics[topicIndex].precepts.add(precept);
      update();
    }
  }

  void createTopic(String title, TopicType type) {
    final newTopic = TopicModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      createdAt: 'Just now',
      precepts: [],
    );

    switch (type) {
      case TopicType.preceptTopics:
        _preceptTopics.insert(0, newTopic);
        break;
      case TopicType.lessonPrecepts:
        _lessonPrecepts.insert(0, newTopic);
        break;
      case TopicType.favorites:
        _favorites.insert(0, newTopic);
        break;
    }
    update();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
