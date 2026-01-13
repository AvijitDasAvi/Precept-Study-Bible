import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../../all_bibles/controller/all_bibles_controller.dart';
import '../../../../core/utils/constants/api_constants.dart';
import '../../../../core/services/network_caller.dart';
import '../../bible_info/controller/bible_info_controller.dart';
import '../service/tts_service.dart';
import '../../../home/widget/add_topic_dialog.dart';
import '../../../../core/utils/localization/localization_service.dart';

class BibleChapterStateController extends GetxController {
  final Book book;
  final int initialChapter;
  final String initialVersion;

  BibleChapterStateController({
    required this.book,
    required this.initialChapter,
    required this.initialVersion,
  });

  late Future<List<String>> _paragraphsFuture;
  final _currentVersion = ''.obs;
  final _selectedParaIndex = Rxn<int>();
  final _selectedParas = <int>{}.obs;
  final _multiSelectMode = false.obs;
  final _lastParagraphs = Rxn<List<String>>();
  List<GlobalKey>? _paraKeys;
  final _currentChapter = 0.obs;
  late TtsService _ttsService;

  String get currentVersion => _currentVersion.value;
  int? get selectedParaIndex => _selectedParaIndex.value;
  Set<int> get selectedParas => _selectedParas.toSet();
  bool get multiSelectMode => _multiSelectMode.value;
  List<String>? get lastParagraphs => _lastParagraphs.value;
  List<GlobalKey>? get paraKeys => _paraKeys;
  int get currentChapter => _currentChapter.value;
  bool get isPlaying => _ttsService.isPlaying;
  bool get repeatSingle => _ttsService.repeatSingle;

  @override
  void onInit() {
    super.onInit();
    _ttsService = Get.put(TtsService());
    _currentVersion.value = initialVersion;
    _currentChapter.value = initialChapter;
    _loadParagraphs();
    _initializeTtsHandler();
  }

  void _initializeTtsHandler() {
    _ttsService.setCompletionHandler(() async {
      final total = (_lastParagraphs.value?.length ?? 0);
      if (_ttsService.repeatSingle) {
        if (_ttsService.playingIndex >= 0 && _ttsService.playingIndex < total) {
          await _speakCurrent();
        } else {
          _ttsService.resetPlayback();
        }
        return;
      }

      if (_ttsService.playQueue != null && _ttsService.playQueue!.isNotEmpty) {
        if (_ttsService.playQueuePos + 1 < _ttsService.playQueue!.length) {
          _ttsService.setPlayQueuePos(_ttsService.playQueuePos + 1);
          final nextIndex = _ttsService.playQueue![_ttsService.playQueuePos];
          _ttsService.setPlayingIndex(nextIndex);
          _selectedParaIndex.value = _ttsService.playingIndex;
          await _speakCurrent();
        } else {
          _ttsService.resetPlayback();
          _selectedParaIndex.value = null;
        }
        return;
      }

      if (_ttsService.playingIndex + 1 < total) {
        _ttsService.setPlayingIndex(_ttsService.playingIndex + 1);
        _selectedParaIndex.value = _ttsService.playingIndex;
        await _speakCurrent();
      } else {
        _ttsService.resetPlayback();
        _selectedParaIndex.value = null;
      }
    });
  }

  void _loadParagraphs() {
    _lastParagraphs.value = null;
    _paraKeys = null;

    _paragraphsFuture = fetchChapterParagraphs(
      bookId: book.id,
      chapter: _currentChapter.value,
      version: _currentVersion.value,
    );

    _paragraphsFuture
        .then((p) {
          _lastParagraphs.value = p;
          _paraKeys = List.generate(p.length, (_) => GlobalKey());
        })
        .catchError((_) {});
  }

  void goToChapter(int chapter) {
    if (chapter < 1 || chapter > book.chapters) return;
    pausePlayback();
    _currentChapter.value = chapter;
    _selectedParaIndex.value = null;
    _ttsService.resetPlayback();
    _lastParagraphs.value = null;
    _paraKeys = null;
    _loadParagraphs();
  }

  void goPrevChapter() {
    if (_currentChapter.value > 1) {
      goToChapter(_currentChapter.value - 1);
    } else {
      EasyLoading.showInfo(
        LocalizationService.translate('already_at_first_chapter'),
      );
    }
  }

  void goNextChapter() {
    if (_currentChapter.value < book.chapters) {
      goToChapter(_currentChapter.value + 1);
    } else {
      EasyLoading.showInfo(
        LocalizationService.translate('already_at_last_chapter'),
      );
    }
  }

  void onChangeVersion(String v) {
    if (v == _currentVersion.value) return;
    _currentVersion.value = v;
    _selectedParaIndex.value = null;
    pausePlayback();
    _lastParagraphs.value = null;
    _loadParagraphs();
  }

  void pausePlayback() {
    _ttsService.stop();
  }

  Future<void> _speakCurrent() async {
    final paras = _lastParagraphs.value ?? [];
    int indexToSpeak = _ttsService.playingIndex;
    if (_ttsService.playQueue != null &&
        _ttsService.playQueuePos >= 0 &&
        _ttsService.playQueuePos < _ttsService.playQueue!.length) {
      indexToSpeak = _ttsService.playQueue![_ttsService.playQueuePos];
    }
    if (indexToSpeak < 0 || indexToSpeak >= paras.length) return;

    _selectedParaIndex.value = indexToSpeak;
    _ttsService.setPlayingIndex(indexToSpeak);
    await scrollToIndex(indexToSpeak);

    final text = paras[indexToSpeak];
    await _ttsService.speak(text);
  }

  void toggleSelect(int index) {
    if (_selectedParas.contains(index)) {
      _selectedParas.remove(index);
    } else {
      _selectedParas.add(index);
    }
    if (_selectedParas.length == 1) {
      _selectedParaIndex.value = _selectedParas.first;
    } else if (_selectedParas.isEmpty) {
      _selectedParaIndex.value = null;
      _multiSelectMode.value = false;
    } else {
      _selectedParaIndex.value = null;
    }
  }

  void enterMultiSelect(int index) {
    _multiSelectMode.value = true;
    _selectedParas.clear();
    _selectedParas.add(index);
    _selectedParaIndex.value = null;
  }

  void exitMultiSelect() {
    _multiSelectMode.value = false;
    _selectedParas.clear();
    _selectedParaIndex.value = null;
  }

  Future<void> scrollToIndex(int index) async {
    try {
      if (_paraKeys == null || index < 0 || index >= _paraKeys!.length) {
        return;
      }
      final context = _paraKeys![index].currentContext;
      if (context != null && context.mounted) {
        await Scrollable.ensureVisible(
          context,
          duration: Duration(milliseconds: 300),
          alignment: 0.12,
        );
      }
    } catch (_) {}
  }

  void togglePlay() {
    final paras = _lastParagraphs.value ?? [];
    if (_ttsService.isPlaying) {
      _ttsService.pause();
      return;
    }

    _ttsService.setPlaying(true);
    final index =
        (_selectedParaIndex.value != null &&
            _selectedParaIndex.value! < paras.length)
        ? _selectedParaIndex.value!
        : 0;
    _ttsService.setPlayingIndex(index);
    _selectedParaIndex.value = _ttsService.playingIndex;

    _speakCurrent();
  }

  Future<void> copySelectedText() async {
    final paras = _lastParagraphs.value ?? [];
    if (_selectedParas.isEmpty && _selectedParaIndex.value == null) {
      EasyLoading.showInfo(
        LocalizationService.translate('select_paragraphs_to_copy'),
      );
      return;
    }
    List<int> indices;
    if (_selectedParas.isNotEmpty) {
      indices = _selectedParas.toList();
      indices.sort();
    } else {
      indices = [_selectedParaIndex.value!];
    }
    final out = indices.map((i) => paras[i]).join('\n\n');
    await Clipboard.setData(ClipboardData(text: out));
    EasyLoading.showSuccess(
      LocalizationService.translate('copied_to_clipboard'),
    );
  }

  void shareSelectedText() {
    pausePlayback();
    final paras = _lastParagraphs.value ?? [];
    if (_selectedParas.isEmpty && _selectedParaIndex.value == null) {
      EasyLoading.showInfo(
        LocalizationService.translate('select_paragraphs_to_share'),
      );
      return;
    }
    List<int> indices;
    if (_selectedParas.isNotEmpty) {
      indices = _selectedParas.toList();
      indices.sort();
    } else {
      indices = [_selectedParaIndex.value!];
    }
    final text = indices.map((i) => paras[i]).join('\n\n');
    SharePlus.instance.share(ShareParams(text: text));
  }

  void playSelectedText() {
    if (_selectedParas.isEmpty && _selectedParaIndex.value == null) {
      EasyLoading.showInfo(
        LocalizationService.translate('select_paragraphs_to_play'),
      );
      return;
    }
    if (_selectedParas.isNotEmpty) {
      final indices = _selectedParas.toList()..sort();
      _ttsService.setPlaying(true);
      _ttsService.setPlayQueue(indices);
      _ttsService.setPlayQueuePos(0);
      _ttsService.setPlayingIndex(_ttsService.playQueue![0]);
      _selectedParaIndex.value = _ttsService.playingIndex;
      _speakCurrent();
    } else {
      togglePlay();
    }
  }

  void toggleRepeat() {
    if (_selectedParas.isEmpty && _selectedParaIndex.value == null) {
      EasyLoading.showInfo(
        LocalizationService.translate('select_paragraphs_to_repeat'),
      );
      return;
    }
    _ttsService.setRepeatSingle(!_ttsService.repeatSingle);
    EasyLoading.showInfo(
      _ttsService.repeatSingle
          ? LocalizationService.translate('repeat_single_enabled')
          : LocalizationService.translate('repeat_disabled'),
    );
  }

  void onParagraphTap(int index) {
    if (_multiSelectMode.value) {
      toggleSelect(index);
      return;
    }
    _selectedParaIndex.value = index == _selectedParaIndex.value ? null : index;
    _selectedParas.clear();
    if (index != _selectedParaIndex.value) {
      scrollToIndex(index);
    }
  }

  void onParagraphLongPress(int index) {
    enterMultiSelect(index);
  }

  void onAddToTopic() {
    if (_selectedParas.isEmpty && _selectedParaIndex.value == null) {
      EasyLoading.showInfo(
        LocalizationService.translate('select_paragraphs_to_add_to_topic'),
      );
      return;
    }

    final paras = _lastParagraphs.value ?? [];
    List<int> indices;
    if (_selectedParas.isNotEmpty) {
      indices = _selectedParas.toList()..sort();
    } else {
      indices = [_selectedParaIndex.value!];
    }

    // Format each verse with book name, chapter, and verse number
    final formattedVerses = indices.map((i) {
      final verseNumber =
          i + 1; // Convert 0-based index to 1-based verse number
      final verseText = paras[i];
      return '${book.title} ${_currentChapter.value}:$verseNumber - $verseText';
    }).toList();

    final selectedText = formattedVerses.join('\n\n');
    final paraNumbers = _formatParagraphNumbers(indices);
    final chapterRef = '${book.title} ${_currentChapter.value}:$paraNumbers';

    Get.dialog(
      Dialog(
        child: AddTopicDialog(
          initialPreceptTitle: chapterRef,
          initialPreceptContent: selectedText,
        ),
      ),
    ).then((_) {
      exitMultiSelect();
      _selectedParaIndex.value = null;
      EasyLoading.showInfo(
        LocalizationService.translate('topic_dialog_closed'),
      );
    });
  }

  String _formatParagraphNumbers(List<int> indices) {
    if (indices.isEmpty) return '';
    if (indices.length == 1) return '${indices.first + 1}';

    // Sort indices to ensure proper processing
    indices.sort();

    // Convert 0-based indices to 1-based paragraph numbers
    final paraNumbers = indices.map((i) => i + 1).toList();

    List<String> ranges = [];
    int start = paraNumbers.first;
    int end = start;

    for (int i = 1; i < paraNumbers.length; i++) {
      if (paraNumbers[i] == end + 1) {
        // Consecutive number, extend the range
        end = paraNumbers[i];
      } else {
        // Non-consecutive, finalize current range
        if (start == end) {
          ranges.add('$start');
        } else {
          ranges.add('$start-$end');
        }
        start = paraNumbers[i];
        end = start;
      }
    }

    // Add the final range
    if (start == end) {
      ranges.add('$start');
    } else {
      ranges.add('$start-$end');
    }

    return ranges.join(', ');
  }

  Future<List<String>> get paragraphsFuture => _paragraphsFuture;

  static Future<List<String>> fetchChapterParagraphs({
    required String bookId,
    required int chapter,
    required String version,
  }) async {
    try {
      // Handle Spanish translation
      if (version == 'Spanish') {
        return await _fetchSpanishChapter(bookId: bookId, chapter: chapter);
      }

      String endpointBase;
      if (version == 'KJV') {
        endpointBase = ApiConstants.kjv;
      } else if (version == 'KJVA') {
        endpointBase = ApiConstants.kjva;
      } else if (version == 'KJV+') {
        endpointBase = ApiConstants.kjvcp;
      } else {
        endpointBase = ApiConstants.kjv;
      }

      final url = '$endpointBase/$bookId/$chapter';
      final caller = NetworkCaller();
      final resp = await caller.getRequest(url);

      if (!resp.isSuccess) {
        throw Exception('network error');
      }

      final respData = resp.responseData;
      final data = (respData is Map)
          ? (respData['data'] ?? respData)
          : respData;
      final chapterNode = (data is Map)
          ? (data['chapter'] ??
                (data['data'] is Map ? data['data']['chapter'] : null) ??
                data)
          : data;

      final content = chapterNode['content'];
      if (content == null || content is! List) {
        return [];
      }

      final List<String> paragraphs = [];
      for (final item in content) {
        if (item is Map && item['content'] != null) {
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
            if (parts.isNotEmpty) paragraphs.add(parts.join(' '));
          }
        } else if (item is String) {
          paragraphs.add(item);
        }
      }

      return paragraphs;
    } catch (e) {
      await Future.delayed(Duration(milliseconds: 200));

      final allBooks = AllBiblesController.categories.values
          .expand((l) => l)
          .toList(growable: false);

      final book = allBooks.firstWhere(
        (b) => b.id == bookId,
        orElse: () => allBooks.first,
      );

      return List.generate(
        6,
        (i) => '${i + 1}. ${book.title} - Chapter $chapter paragraph ${i + 1}.',
      );
    }
  }

  static Future<List<String>> _fetchSpanishChapter({
    required String bookId,
    required int chapter,
  }) async {
    try {
      // Map book ID to Spanish book name (e.g., "GEN" -> "genesis")
      // This is based on the API documentation which expects book names like "genesis"
      final bookName = _mapBookIdToSpanishName(bookId);

      if (bookName.isEmpty) {
        throw Exception('Unknown book ID: $bookId');
      }

      final spanishUrl = ApiConstants.spanishBookByChapter
          .replaceAll('{bookName}', bookName)
          .replaceAll('{chapter}', chapter.toString());

      debugPrint('🔍 Fetching Spanish chapter from: $spanishUrl');
      debugPrint(
        '🔍 Book ID: $bookId -> Book Name: $bookName, Chapter: $chapter',
      );

      final caller = NetworkCaller();
      final resp = await caller.getRequest(spanishUrl);

      debugPrint('🔍 Spanish API response status: ${resp.statusCode}');

      if (!resp.isSuccess) {
        throw Exception('Failed to fetch Spanish chapter: ${resp.statusCode}');
      }

      final respData = resp.responseData;
      debugPrint('🔍 Spanish API response data type: ${respData.runtimeType}');
      debugPrint(
        '🔍 Spanish API response keys: ${(respData is Map) ? respData.keys : 'N/A'}',
      );

      if (respData is Map && respData.containsKey('text')) {
        final verses = respData['text'];
        if (verses is List && verses.isNotEmpty) {
          debugPrint('🔍 Successfully fetched ${verses.length} Spanish verses');
          // Convert verses list to paragraphs list (each verse is a paragraph)
          return verses
              .map((v) => v.toString())
              .where((v) => v.trim().isNotEmpty)
              .toList();
        }
      }

      throw Exception('Unexpected response format: $respData');
    } catch (e) {
      debugPrint('❌ Error fetching Spanish chapter: $e');
      // Return fallback verses with generic message
      return List.generate(
        6,
        (i) =>
            '${i + 1}. ${_mapBookIdToSpanishName(bookId)} - Capítulo $chapter verso ${i + 1}.',
      );
    }
  }

  /// Maps book IDs (like "GEN", "EXO") to their Spanish API names (like "genesis", "exodus")
  static String _mapBookIdToSpanishName(String bookId) {
    final bookMap = {
      'GEN': 'genesis',
      'EXO': 'exodus',
      'LEV': 'leviticus',
      'NUM': 'numbers',
      'DEU': 'deuteronomy',
      'JOS': 'joshua',
      'JDG': 'judges',
      'RUT': 'ruth',
      '1SA': '1-samuel',
      '2SA': '2-samuel',
      '1KI': '1-kings',
      '2KI': '2-kings',
      '1CH': '1-chronicles',
      '2CH': '2-chronicles',
      'EZR': 'ezra',
      'NEH': 'nehemiah',
      'EST': 'esther',
      'JOB': 'job',
      'PSA': 'psalms',
      'PRO': 'proverbs',
      'ECC': 'ecclesiastes',
      'SNG': 'song-of-solomon',
      'ISA': 'isaiah',
      'JER': 'jeremiah',
      'LAM': 'lamentations',
      'EZK': 'ezekiel',
      'DAN': 'daniel',
      'HOS': 'hosea',
      'JOL': 'joel',
      'AMO': 'amos',
      'OBA': 'obadiah',
      'JON': 'jonah',
      'MIC': 'micah',
      'NAM': 'nahum',
      'HAB': 'habakkuk',
      'ZEP': 'zephaniah',
      'HAG': 'haggai',
      'ZEC': 'zechariah',
      'MAL': 'malachi',
      'MAT': 'matthew',
      'MRK': 'mark',
      'LUK': 'luke',
      'JHN': 'john',
      'ACT': 'acts',
      'ROM': 'romans',
      '1CO': '1-corinthians',
      '2CO': '2-corinthians',
      'GAL': 'galatians',
      'EPH': 'ephesians',
      'PHP': 'philippians',
      'COL': 'colossians',
      '1TH': '1-thessalonians',
      '2TH': '2-thessalonians',
      '1TI': '1-timothy',
      '2TI': '2-timothy',
      'TIT': 'titus',
      'PHM': 'philemon',
      'HEB': 'hebrews',
      'JAS': 'james',
      '1PE': '1-peter',
      '2PE': '2-peter',
      '1JN': '1-john',
      '2JN': '2-john',
      '3JN': '3-john',
      'JUD': 'jude',
      'REV': 'revelation',
    };

    return bookMap[bookId] ?? bookId.toLowerCase();
  }

  static String? chapterTitle({required String bookId, required int chapter}) {
    if (bookId.toLowerCase().contains('joshua') && chapter == 1) {
      return 'The Promised Land';
    }
    return null;
  }

  static List<String> availableVersions() =>
      BibleInfoController.availableVersions();
}
