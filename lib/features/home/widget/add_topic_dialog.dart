import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:calvinlockhart/core/services/network_caller.dart';
import 'package:calvinlockhart/core/utils/constants/api_constants.dart';
import '../services/bible_service.dart';
import 'package:calvinlockhart/features/home/widget/precept_controllers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widget/add_topic_header.dart';
import '../widget/topic_name_input.dart';
import '../widget/precepts_section.dart';
import '../widget/destination_selector.dart';
import '../widget/save_topic_button.dart';
import 'package:calvinlockhart/core/utils/localization/localization_service.dart';
import '../../topics/models/topic_models.dart';
import '../../topics/controller/topics_controller.dart';

class AddTopicDialog extends StatefulWidget {
  final String? initialTopicName;
  final String? initialPreceptTitle;
  final String? initialPreceptContent;
  final int? initialDestination;
  final String? initialTopicId;
  final TopicModel? topicToEdit;
  final TopicType? editingTopicType;
  final TopicsController? editingTopicController;

  const AddTopicDialog({
    super.key,
    this.initialTopicName,
    this.initialPreceptTitle,
    this.initialPreceptContent,
    this.initialDestination,
    this.initialTopicId,
    this.topicToEdit,
    this.editingTopicType,
    this.editingTopicController,
  });

  @override
  State<AddTopicDialog> createState() => _AddTopicDialogState();
}

class _AddTopicDialogState extends State<AddTopicDialog> {
  late final TextEditingController topicController;
  final List<PreceptControllers> precepts = [];
  int? selectedDestination;
  bool showError = false;
  bool showDestinationError = false;
  bool showTopicNameError = false;
  final NetworkCaller _caller = NetworkCaller();
  Timer? _debounce;
  List<Map<String, dynamic>> suggestions = [];
  String? selectedTopicId;
  bool _suppressSuggestions = false;
  String? _lastSelectedText;
  late bool isEditing;

  @override
  void initState() {
    super.initState();
    isEditing = widget.topicToEdit != null;

    // Initialize topic controller
    topicController = TextEditingController(
      text: isEditing
          ? widget.topicToEdit!.title
          : (widget.initialTopicName ?? ''),
    );

    topicController.addListener(_onTopicChanged);

    // Handle editing mode - load existing precepts
    if (isEditing) {
      selectedTopicId = widget.topicToEdit!.id;
      _suppressSuggestions = true;
      _lastSelectedText = widget.topicToEdit!.title;

      // Load destination from existing topic
      if (widget.topicToEdit!.destination != null) {
        switch (widget.topicToEdit!.destination) {
          case 'PRECEPT_TOPIC':
            selectedDestination = 0;
            break;
          case 'LESSON_PRECEPTS':
            selectedDestination = 1;
            break;
          case 'FAVORITES':
            selectedDestination = 2;
            break;
        }
      } else {
        // Fallback to topic type
        switch (widget.editingTopicType) {
          case TopicType.preceptTopics:
            selectedDestination = 0;
            break;
          case TopicType.lessonPrecepts:
            selectedDestination = 1;
            break;
          case TopicType.favorites:
            selectedDestination = 2;
            break;
          default:
            selectedDestination = 0;
        }
      }

      // Load existing precepts
      for (final precept in widget.topicToEdit!.precepts) {
        final controllers = PreceptControllers();
        controllers.title.text = precept.reference;
        controllers.description.text = precept.content;
        controllers.preceptId = precept.id;
        controllers.title.addListener(
          () => _addPreceptTitleListener(controllers, precepts.length),
        );
        precepts.add(controllers);
      }
    } else {
      // Handle adding new precepts
      if (widget.initialPreceptTitle != null ||
          widget.initialPreceptContent != null) {
        final preceptController = PreceptControllers();
        preceptController.title.text = widget.initialPreceptTitle ?? '';
        preceptController.description.text = widget.initialPreceptContent ?? '';
        _addPreceptTitleListener(preceptController, 0);
        precepts.add(preceptController);
        selectedDestination = widget.initialDestination ?? 0;
      } else {
        selectedDestination = widget.initialDestination;
      }

      // Set the selectedTopicId if provided
      if (widget.initialTopicId != null) {
        selectedTopicId = widget.initialTopicId;
        _suppressSuggestions = true;
        _lastSelectedText = widget.initialTopicName;
      }
    }
  }

  @override
  void dispose() {
    topicController.removeListener(_onTopicChanged);
    _debounce?.cancel();
    topicController.dispose();
    for (final p in precepts) {
      p.dispose();
    }
    super.dispose();
  }

  void _onTopicChanged() {
    final q = topicController.text.trim();

    if (_suppressSuggestions &&
        _lastSelectedText != null &&
        q == _lastSelectedText) {
      return;
    }

    if (_suppressSuggestions &&
        _lastSelectedText != null &&
        q != _lastSelectedText) {
      _suppressSuggestions = false;
      _lastSelectedText = null;
    }

    selectedTopicId = null;
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(Duration(milliseconds: 400), () {
      if (q.isEmpty) {
        setState(() => suggestions = []);
        return;
      }
      _fetchTopicSuggestions(q);
    });
  }

  Future<void> _fetchTopicSuggestions(String query) async {
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

      final lower = query.toLowerCase();
      final filtered = <Map<String, dynamic>>[];
      Map<String, dynamic>? exactMatch;

      for (final item in data) {
        if (item is Map<String, dynamic>) {
          final name = (item['name'] ?? '').toString();
          if (name.toLowerCase().contains(lower)) {
            filtered.add(Map.from(item));
          }
          // Check for exact match
          if (name.toLowerCase() == lower) {
            exactMatch = item;
          }
        }
      }

      if (!mounted) return;

      // If exact match found, select it and update destination
      if (exactMatch != null) {
        final id = (exactMatch['id'] ?? '').toString();
        final destination = (exactMatch['destination'] ?? '')
            .toString()
            .toUpperCase();
        int? newDestination;
        if (destination == 'PRECEPT_TOPIC') {
          newDestination = 0;
        } else if (destination == 'LESSON_PRECEPTS') {
          newDestination = 1;
        } else if (destination == 'FAVORITES') {
          newDestination = 2;
        }

        setState(() {
          suggestions = filtered;
          selectedTopicId = id;
          if (newDestination != null) {
            selectedDestination = newDestination;
          }
        });
      } else {
        setState(() => suggestions = filtered);
        selectedTopicId = null;
      }
    } catch (e) {
      // ignore
    }
  }

  Future<void> _fetchPreceptTitleSuggestions(
    String query,
    int preceptIndex,
  ) async {
    try {
      if (preceptIndex >= precepts.length) return;
      final preceptCtrl = precepts[preceptIndex];
      final bookChapterVersePattern = RegExp(r'^(.+?)\s+(\d+):(.+)$');
      final match = bookChapterVersePattern.firstMatch(query.trim());

      debugPrint('🔍 Query: "$query"');
      debugPrint('🔍 Pattern match: ${match != null}');

      if (match != null) {
        final bookName = match.group(1)!.trim();
        final chapter = int.tryParse(match.group(2)!) ?? 1;
        final versesPart = match.group(3)!.trim();
        debugPrint(
          '🔍 Parsed - Book: "$bookName", Chapter: $chapter, Verses: "$versesPart"',
        );
        final combined = await BibleService.fetchVersesCombinedText(
          _caller,
          bookName,
          chapter,
          versesPart,
        );
        if (combined != null) {
          final preceptCtrl = precepts[preceptIndex];
          if (!mounted) return;
          setState(() {
            preceptCtrl.description.text = combined;
            preceptCtrl.titleSuggestions.clear();
          });
        } else {
          // Invalid verse, clear the description
          if (!mounted) return;
          setState(() {
            preceptCtrl.description.text = '';
            preceptCtrl.titleSuggestions.clear();
          });
        }
        return;
      }

      final books = await BibleService.fetchBibleBooks(_caller);
      final lower = query.toLowerCase();
      final filtered = books.where((book) {
        final name = book['name'].toString().toLowerCase();
        return name.contains(lower);
      }).toList();

      if (!mounted) return;
      setState(() {
        preceptCtrl.titleSuggestions.clear();
        preceptCtrl.titleSuggestions.addAll(filtered);
      });
    } catch (e) {
      debugPrint('🔍 Error in _fetchPreceptTitleSuggestions: $e');
    }
  }

  void _addPreceptTitleListener(PreceptControllers preceptCtrl, int index) {
    preceptCtrl.title.addListener(() {
      final query = preceptCtrl.title.text.trim();

      if (preceptCtrl.suppressTitleSuggestions &&
          preceptCtrl.lastSelectedTitleText != null &&
          query == preceptCtrl.lastSelectedTitleText) {
        return;
      }

      if (preceptCtrl.suppressTitleSuggestions &&
          preceptCtrl.lastSelectedTitleText != null &&
          query != preceptCtrl.lastSelectedTitleText) {
        preceptCtrl.suppressTitleSuggestions = false;
        preceptCtrl.lastSelectedTitleText = null;
      }

      if (preceptCtrl.debounce?.isActive ?? false) {
        preceptCtrl.debounce!.cancel();
      }

      preceptCtrl.debounce = Timer(Duration(milliseconds: 400), () {
        if (query.isEmpty) {
          setState(() {
            preceptCtrl.titleSuggestions.clear();
            // Clear description when title is cleared
            preceptCtrl.description.text = '';
          });
          return;
        }
        _fetchPreceptTitleSuggestions(query, index);
      });
    });

    // Add listener to description field to auto-remove empty precepts
    preceptCtrl.description.addListener(() {
      final title = preceptCtrl.title.text.trim();
      final description = preceptCtrl.description.text.trim();

      // Only remove precept if both title and description are empty
      // and there's more than one precept
      // and this precept hasn't already been marked for removal
      if (title.isEmpty &&
          description.isEmpty &&
          precepts.length > 1 &&
          !preceptCtrl.isMarkedForRemoval) {
        // Find this specific precept in the list
        int removeIndex = -1;
        for (int i = 0; i < precepts.length; i++) {
          if (identical(precepts[i], preceptCtrl)) {
            removeIndex = i;
            break;
          }
        }

        if (removeIndex != -1 && mounted) {
          // Mark this precept for removal to prevent duplicate removals
          preceptCtrl.isMarkedForRemoval = true;

          // Defer the disposal to avoid issues with listener callbacks
          Future.microtask(() {
            if (mounted && removeIndex >= 0 && removeIndex < precepts.length) {
              // Double-check the precept is still the same before removing
              if (identical(precepts[removeIndex], preceptCtrl)) {
                setState(() {
                  precepts[removeIndex].dispose();
                  precepts.removeAt(removeIndex);
                });
              }
            }
          });
        }
      }
    });
  }

  void _showBooksSelector() {
    showDialog(
      context: context,
      builder: (context) => _BooksSelectionDialog(
        onSelected: (bookName, chapter, verse, content) {
          // Check if there's an empty precept to fill
          int emptyPrecptIndex = -1;
          for (int i = 0; i < precepts.length; i++) {
            if (precepts[i].title.text.trim().isEmpty &&
                precepts[i].description.text.trim().isEmpty) {
              emptyPrecptIndex = i;
              break;
            }
          }

          if (emptyPrecptIndex != -1) {
            // Fill the empty precept
            precepts[emptyPrecptIndex].title.text = '$bookName $chapter:$verse';
            precepts[emptyPrecptIndex].description.text = content;
            setState(() {
              showError = false;
            });
          } else {
            // Add a new precept if no empty ones exist
            final p = PreceptControllers();
            p.title.text = '$bookName $chapter:$verse';
            p.description.text = content;
            _addPreceptTitleListener(p, precepts.length);
            setState(() {
              precepts.add(p);
              showError = false;
            });
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final suggestionsBgColor = isDarkMode ? Colors.grey[850] : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    return Padding(
      padding: EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AddTopicHeader(
              showFromSelected: widget.initialPreceptContent != null,
              onClose: () => Navigator.of(context).pop(),
            ),
            SizedBox(height: 12),
            if (showTopicNameError)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Color(0xFFFFEBEB),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Color(0xFFDA5963)),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        LocalizationService.translate(
                          'please_enter_topic_name',
                        ),
                        style: TextStyle(color: Color(0xFFDA5963)),
                      ),
                    ),
                  ],
                ),
              ),
            TopicNameInput(controller: topicController, readOnly: isEditing),
            if (suggestions.isNotEmpty && !isEditing)
              Container(
                margin: EdgeInsets.only(top: 6),
                padding: EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: suggestionsBgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 150),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: suggestions.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 1,
                      color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                    ),
                    itemBuilder: (context, sugIndex) {
                      final item = suggestions[sugIndex];
                      final name = (item['name'] ?? '').toString();
                      final id = (item['id'] ?? '').toString();
                      return ListTile(
                        title: Text(name, style: TextStyle(color: textColor)),
                        onTap: () {
                          _suppressSuggestions = true;
                          _lastSelectedText = name;
                          topicController.text = name;
                          selectedTopicId = id;

                          // Update destination based on selected topic
                          final destination = (item['destination'] ?? '')
                              .toString()
                              .toUpperCase();
                          int? newDestination;
                          if (destination == 'PRECEPT_TOPIC') {
                            newDestination = 0;
                          } else if (destination == 'LESSON_PRECEPTS') {
                            newDestination = 1;
                          } else if (destination == 'FAVORITES') {
                            newDestination = 2;
                          }

                          setState(() {
                            suggestions.clear();
                            if (newDestination != null) {
                              selectedDestination = newDestination;
                            }
                          });
                        },
                      );
                    },
                  ),
                ),
              ),
            SizedBox(height: 16),
            PreceptsSection(
              precepts: precepts,
              onAddPrecept: (p) => setState(() {
                _addPreceptTitleListener(p, precepts.length);
                precepts.add(p);
                showError = false;
              }),
              onRemovePrecept: (idx) {
                if (idx >= 0 && idx < precepts.length) {
                  setState(() {
                    precepts[idx].dispose();
                    precepts.removeAt(idx);
                  });
                }
              },
              onAttachListener: (idx, p) => _addPreceptTitleListener(p, idx),
              onAddFromBooks: _showBooksSelector,
              allowRemove: isEditing,
              isEditing: isEditing,
            ),
            SizedBox(height: 8),
            if (!isEditing)
              DestinationSelector(
                selected: selectedDestination,
                onSelected: (id) => setState(() {
                  selectedDestination = id;
                  showDestinationError = false;
                }),
              ),
            if (!isEditing) SizedBox(height: 12),
            if (showDestinationError)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Color(0xFFFFEBEB),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Color(0xFFDA5963)),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        LocalizationService.translate(
                          'please_select_destination',
                        ),
                        style: TextStyle(color: Color(0xFFDA5963)),
                      ),
                    ),
                  ],
                ),
              ),
            SizedBox(height: 12),
            if (showError)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Color(0xFFFFEBEB),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Color(0xFFDA5963)),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        LocalizationService.translate('need_add_precept_first'),
                        style: TextStyle(color: Color(0xFFDA5963)),
                      ),
                    ),
                  ],
                ),
              ),
            SizedBox(height: 12),
            SaveTopicButton(onSave: _onSave),
            SizedBox(height: 6),
          ],
        ),
      ),
    );
  }

  bool _isValidReferenceFormat(String reference) {
    // Pattern: "BookName Chapter:Verse" or "BookName Chapter : Verse"
    // Supports comma-separated verses, ranges with hyphen, and spaces
    // Example: "Matthew 4:3", "Ruth 1:1-5", "Ruth 1:1,2,3", "EZEKIEL 1 : 1"
    final regex = RegExp(r'^[A-Za-z0-9\s]+\s\d+\s*:\s*\d+(?:\s*[-,]\s*\d+)*$');
    return regex.hasMatch(reference.trim());
  }

  Future<void> _onSave() async {
    // In editing mode, save the changes
    if (isEditing) {
      final hasDestination = selectedDestination != null;
      final topicName = topicController.text.trim();

      // Check if any precept has content
      final hasAny = precepts.any(
        (c) =>
            (c.title.text.trim().isNotEmpty) ||
            (c.description.text.trim().isNotEmpty),
      );

      // Validate that all precepts with content have BOTH title and description filled
      bool hasIncompletePrecept = false;
      for (final precept in precepts) {
        final reference = precept.title.text.trim();
        final content = precept.description.text.trim();
        if ((reference.isNotEmpty && content.isEmpty) ||
            (reference.isEmpty && content.isNotEmpty)) {
          hasIncompletePrecept = true;
          break;
        }
      }

      if (hasIncompletePrecept) {
        EasyLoading.showError(
          'Each precept must have both a reference and description',
        );
        return;
      }

      // Validate reference format for all precepts with content
      bool hasInvalidReference = false;
      for (final precept in precepts) {
        final reference = precept.title.text.trim();
        final content = precept.description.text.trim();
        if (reference.isNotEmpty && content.isNotEmpty) {
          if (!_isValidReferenceFormat(reference)) {
            hasInvalidReference = true;
            break;
          }
        }
      }

      if (hasInvalidReference) {
        EasyLoading.showError(
          'Invalid reference format. Use "BookName Chapter:Verse" (e.g., "Matthew 4:3")',
        );
        return;
      }

      setState(() {
        showError = !hasAny;
        showDestinationError = !hasDestination;
        showTopicNameError = topicName.isEmpty;
      });
      if (!hasAny || !hasDestination || showTopicNameError) return;

      final dest = selectedDestination == 0
          ? 'PRECEPT_TOPIC'
          : selectedDestination == 1
          ? 'LESSON_PRECEPTS'
          : 'FAVORITES';

      final List<Map<String, String>> preceptPayload = precepts
          .map(
            (c) => {
              'reference': c.title.text.trim(),
              'content': c.description.text.trim(),
            },
          )
          .toList();

      try {
        final success = await widget.editingTopicController!.editTopic(
          widget.topicToEdit!.id,
          topicName,
          dest,
          preceptPayload,
          widget.editingTopicType!,
        );

        if (success) {
          EasyLoading.showSuccess(
            LocalizationService.translate('topic_saved_success'),
          );
          if (mounted) Navigator.of(context).pop();
        } else {
          EasyLoading.showError(
            LocalizationService.translate('error_saving_topic'),
          );
        }
      } catch (e) {
        debugPrint('Error saving topic: $e');
        EasyLoading.showError(
          LocalizationService.translate('error_saving_topic'),
        );
      }
      return;
    }

    final hasAny = precepts.any(
      (c) =>
          (c.title.text.trim().isNotEmpty) ||
          (c.description.text.trim().isNotEmpty),
    );
    final hasDestination = selectedDestination != null;
    final topicName = topicController.text.trim();

    // Validate that all precepts with content have BOTH title and description filled
    bool hasIncompletePrecept = false;
    for (final precept in precepts) {
      final reference = precept.title.text.trim();
      final content = precept.description.text.trim();
      if ((reference.isNotEmpty && content.isEmpty) ||
          (reference.isEmpty && content.isNotEmpty)) {
        hasIncompletePrecept = true;
        break;
      }
    }

    if (hasIncompletePrecept) {
      EasyLoading.showError(
        'Each precept must have both a reference and description',
      );
      return;
    }

    // Validate reference format for all precepts with content
    bool hasInvalidReference = false;
    for (final precept in precepts) {
      final reference = precept.title.text.trim();
      final content = precept.description.text.trim();
      if (reference.isNotEmpty && content.isNotEmpty) {
        if (!_isValidReferenceFormat(reference)) {
          hasInvalidReference = true;
          break;
        }
      }
    }

    if (hasInvalidReference) {
      EasyLoading.showError(
        'Invalid reference format. Use "BookName Chapter:Verse" (e.g., "Matthew 4:3")',
      );
      return;
    }

    setState(() {
      showError = !hasAny;
      showDestinationError = !hasDestination;
      showTopicNameError =
          topicName.isEmpty &&
          (selectedTopicId == null || selectedTopicId!.isEmpty);
    });
    if (!hasAny || !hasDestination || showTopicNameError) return;

    final dest = selectedDestination == 0
        ? 'PRECEPT_TOPIC'
        : selectedDestination == 1
        ? 'LESSON_PRECEPTS'
        : 'FAVORITES';

    final List<Map<String, String>> preceptPayload = precepts
        .map(
          (c) => {
            'reference': c.title.text.trim(),
            'content': c.description.text.trim(),
          },
        )
        .toList();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token') ?? '';
      final authHeader = token.isNotEmpty ? 'Bearer $token' : '';

      if (selectedTopicId != null && selectedTopicId!.isNotEmpty) {
        // Adding to existing topic: use addPreceptToTopic endpoint
        final url = ApiConstants.addPreceptToTopic.replaceAll(
          '{topicId}',
          selectedTopicId!,
        );
        final body = {'precepts': preceptPayload};
        await _caller.postRequest(url, body: body, token: authHeader);
      } else {
        // Creating new topic
        final body = {
          'name': topicController.text.trim(),
          'destination': dest,
          'precepts': preceptPayload,
        };
        await _caller.postRequest(
          ApiConstants.postTopic,
          body: body,
          token: authHeader,
        );
      }
    } catch (e) {
      // ignore for now
    }

    // Refresh the topics controller
    try {
      final topicsController = Get.find<TopicsController>();
      await topicsController.refreshTopics();
    } catch (e) {
      debugPrint('Topics controller not found, skipping refresh: $e');
    }

    if (mounted) Navigator.of(context).pop();
    EasyLoading.showSuccess(
      LocalizationService.translate('topic_saved_success'),
    );
  }
}

class _BooksSelectionDialog extends StatefulWidget {
  final void Function(
    String bookName,
    String chapter,
    String verse,
    String content,
  )
  onSelected;

  const _BooksSelectionDialog({required this.onSelected});

  @override
  State<_BooksSelectionDialog> createState() => _BooksSelectionDialogState();
}

class _BooksSelectionDialogState extends State<_BooksSelectionDialog> {
  final NetworkCaller _caller = NetworkCaller();
  List<Map<String, dynamic>> books = [];
  bool isLoading = true;
  String? selectedBook;
  String? selectedChapter;
  List<int> selectedVerses = [];
  String verseContent = '';
  List<Map<String, dynamic>> chapterVerses = [];
  bool isLoadingVerses = false;

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    try {
      final booksList = await BibleService.fetchBibleBooks(_caller);
      setState(() {
        books = booksList;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> _loadChapterVerses() async {
    if (selectedBook == null || selectedChapter == null) return;

    setState(() => isLoadingVerses = true);
    try {
      // Fetch the entire chapter at once
      final versesList = await _fetchEntireChapter();

      setState(() {
        chapterVerses = versesList;
        isLoadingVerses = false;
      });
    } catch (e) {
      debugPrint('Error loading verses: $e');
      setState(() => isLoadingVerses = false);
    }
  }

  Future<List<Map<String, dynamic>>> _fetchEntireChapter() async {
    try {
      final books = await BibleService.fetchBibleBooks(_caller);
      Map<String, dynamic>? book;
      try {
        book = books.firstWhere(
          (b) =>
              b['name'].toString().toLowerCase() == selectedBook!.toLowerCase(),
        );
      } catch (e) {
        book = null;
      }

      if (book == null) return [];

      final bookId = book['id'].toString();
      final url = '${ApiConstants.kjva}/$bookId/$selectedChapter';
      debugPrint('🔍 Fetching chapter from URL: $url');

      final resp = await _caller.getRequest(url);
      if (!resp.isSuccess) return [];

      final chapterData = resp.responseData;
      final data = (chapterData is Map)
          ? (chapterData['data'] ?? chapterData)
          : chapterData;
      final chapterNode = (data is Map) ? (data['chapter'] ?? data) : data;
      final content = chapterNode['content'];

      if (content == null || content is! List) return [];

      final List<Map<String, dynamic>> verses = [];
      int currentVerse = 1;

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
            final verseText = parts.join(' ');
            if (verseText.isNotEmpty) {
              verses.add({'verse': currentVerse, 'text': verseText.trim()});
            }
          }
          currentVerse++;
        }
      }

      return verses;
    } catch (e) {
      debugPrint('Error fetching chapter: $e');
      return [];
    }
  }

  Future<void> _fetchSelectedVerseContent() async {
    if (selectedBook == null ||
        selectedChapter == null ||
        selectedVerses.isEmpty) {
      return;
    }

    try {
      final verseString = selectedVerses.join(',');
      final content = await BibleService.fetchVersesCombinedText(
        _caller,
        selectedBook!,
        int.parse(selectedChapter!),
        verseString,
      );
      setState(() => verseContent = content ?? '');
    } catch (e) {
      setState(() => verseContent = '');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDarkMode ? Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final hintTextColor = isDarkMode ? Colors.white54 : Colors.black54;
    const headerTitleColor = Color(0xFF334EA5);
    final previewBgColor = isDarkMode ? Colors.grey[800] : Color(0xFFE6E9F4);
    final borderColor = isDarkMode ? Colors.grey[700] : Color(0xFFBFC6CF);
    final selectedBgColor = isDarkMode
        ? headerTitleColor.withValues(alpha: 0.2)
        : Color(0xFF334EA5).withValues(alpha: 0.1);

    return Dialog(
      backgroundColor: bgColor,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Add from Books',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: headerTitleColor,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: textColor),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              SizedBox(height: 16),
              if (isLoading)
                Center(child: CircularProgressIndicator())
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Book selector
                    DropdownButtonFormField<String>(
                      initialValue: selectedBook,
                      hint: Text(
                        'Select Book',
                        style: TextStyle(color: hintTextColor),
                      ),
                      items: books
                          .map(
                            (book) => DropdownMenuItem(
                              value: book['name'].toString(),
                              child: Text(
                                book['name'].toString(),
                                style: TextStyle(color: textColor),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedBook = value;
                          selectedChapter = null;
                          selectedVerses.clear();
                          verseContent = '';
                        });
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: borderColor ?? Colors.grey,
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    // Chapter selector
                    if (selectedBook != null)
                      DropdownButtonFormField<String>(
                        initialValue: selectedChapter,
                        hint: Text(
                          'Select Chapter',
                          style: TextStyle(color: hintTextColor),
                        ),
                        items: List.generate(
                          _getChapterCount(selectedBook!),
                          (i) => DropdownMenuItem(
                            value: (i + 1).toString(),
                            child: Text(
                              'Chapter ${i + 1}',
                              style: TextStyle(color: textColor),
                            ),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            selectedChapter = value;
                            selectedVerses.clear();
                            verseContent = '';
                            chapterVerses.clear();
                            isLoadingVerses = true;
                          });
                          // Automatically fetch verses when chapter is selected
                          _loadChapterVerses();
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: borderColor ?? Colors.grey,
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                      ),
                    SizedBox(height: 12),
                    // Verse selector
                    if (selectedChapter != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Select Verses',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                          SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: borderColor ?? Colors.grey,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: isLoadingVerses
                                ? Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(20),
                                      child: CircularProgressIndicator(),
                                    ),
                                  )
                                : chapterVerses.isEmpty
                                ? Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Text(
                                      'Verses are loading...',
                                      style: TextStyle(color: hintTextColor),
                                    ),
                                  )
                                : ConstrainedBox(
                                    constraints: BoxConstraints(maxHeight: 250),
                                    child: ListView.builder(
                                      itemCount: chapterVerses.length,
                                      itemBuilder: (context, index) {
                                        final verse = chapterVerses[index];
                                        final verseNum =
                                            verse['verse'] ?? (index + 1);
                                        final verseText =
                                            verse['text'] ?? 'Verse $verseNum';
                                        final isSelected = selectedVerses
                                            .contains(verseNum);

                                        return GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              if (isSelected) {
                                                selectedVerses.remove(verseNum);
                                              } else {
                                                selectedVerses.add(verseNum);
                                              }
                                            });
                                            // Automatically fetch verse content when verses are selected
                                            if (selectedVerses.isNotEmpty) {
                                              _fetchSelectedVerseContent();
                                            }
                                          },
                                          child: Container(
                                            color: isSelected
                                                ? selectedBgColor
                                                : Colors.transparent,
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 10,
                                            ),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  width: 24,
                                                  height: 24,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                      color: headerTitleColor,
                                                    ),
                                                    color: isSelected
                                                        ? headerTitleColor
                                                        : Colors.transparent,
                                                  ),
                                                  child: isSelected
                                                      ? Icon(
                                                          Icons.check,
                                                          size: 14,
                                                          color: Colors.white,
                                                        )
                                                      : null,
                                                ),
                                                SizedBox(width: 12),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        'Verse $verseNum',
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color:
                                                              headerTitleColor,
                                                          fontSize: 13,
                                                        ),
                                                      ),
                                                      SizedBox(height: 4),
                                                      Text(
                                                        verseText,
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: textColor,
                                                          height: 1.4,
                                                        ),
                                                        maxLines: 3,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                          ),
                          SizedBox(height: 12),
                          if (selectedVerses.isNotEmpty)
                            Padding(
                              padding: EdgeInsets.only(bottom: 12),
                              child: Wrap(
                                spacing: 8,
                                children: selectedVerses.map((verse) {
                                  return Chip(
                                    label: Text('Verse $verse'),
                                    onDeleted: () {
                                      setState(
                                        () => selectedVerses.remove(verse),
                                      );
                                      // Refresh verse content after deletion
                                      if (selectedVerses.isNotEmpty) {
                                        _fetchSelectedVerseContent();
                                      } else {
                                        setState(() => verseContent = '');
                                      }
                                    },
                                  );
                                }).toList(),
                              ),
                            ),
                        ],
                      ),
                    SizedBox(height: 12),
                    // Preview
                    if (verseContent.isNotEmpty)
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: previewBgColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Preview:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: headerTitleColor,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              verseContent,
                              style: TextStyle(fontSize: 14, color: textColor),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel', style: TextStyle(color: textColor)),
                  ),
                  SizedBox(width: 8),
                  FilledButton(
                    onPressed:
                        verseContent.isNotEmpty && selectedVerses.isNotEmpty
                        ? () {
                            widget.onSelected(
                              selectedBook!,
                              selectedChapter!,
                              selectedVerses.join(','),
                              verseContent,
                            );
                            Navigator.pop(context);
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: headerTitleColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: Text(
                      'Add Precept',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _getChapterCount(String bookName) {
    final book = books.firstWhere(
      (b) => b['name'].toString() == bookName,
      orElse: () => {},
    );
    return int.tryParse(book['chapters']?.toString() ?? '0') ?? 0;
  }
}
