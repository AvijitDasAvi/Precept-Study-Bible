import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/downloaded_topic_model.dart';

class DownloadsController extends GetxController {
  final RxList<DownloadedTopicModel> downloads = <DownloadedTopicModel>[].obs;

  static const String _prefsKey = 'downloaded_topics_v1';

  @override
  void onInit() {
    super.onInit();
    _loadDownloads();
  }

  Future<void> _loadDownloads() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getStringList(_prefsKey) ?? [];
      // Ensure downloads is always cleared first so we don't carry stale state.
      downloads.clear();
      debugPrint(
        '💾 _loadDownloads: found ${data.length} raw entries in prefs',
      );
      if (data.isEmpty) {
        update();
        return;
      }
      var decodeFailures = 0;
      for (final s in data) {
        try {
          downloads.add(DownloadedTopicModel.decode(s));
        } catch (e) {
          decodeFailures++;
          debugPrint('💾 _loadDownloads: failed to decode an entry: $e');
        }
      }
      debugPrint(
        '💾 _loadDownloads: loaded ${downloads.length} entries, $decodeFailures failures',
      );
      update();
    } catch (_) {}
  }

  Future<void> _saveAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = downloads.map((d) => d.encode()).toList();
      await prefs.setStringList(_prefsKey, list);
    } catch (_) {}
  }

  Future<bool> isDownloaded(String topicId) async {
    return downloads.any((d) => d.id == topicId);
  }

  Future<void> downloadTopic(DownloadedTopicModel topic) async {
    try {
      downloads.removeWhere((d) => d.id == topic.id);
      downloads.add(topic);
      await _saveAll();
      update();
    } catch (_) {}
  }

  Future<void> removeDownload(String topicId) async {
    try {
      downloads.removeWhere((d) => d.id == topicId);
      await _saveAll();
      update();
    } catch (_) {}
  }
}
