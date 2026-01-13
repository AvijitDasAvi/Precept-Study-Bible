import 'dart:async';
import 'package:flutter/material.dart';
import 'package:calvinlockhart/core/services/network_caller.dart';
import '../../../core/utils/constants/colors.dart';
import 'precept_controllers.dart';
import 'topic_name_section.dart';
import 'destination_selector_widget.dart';
import 'precepts_section.dart';
import '../services/edit_topic_bible_service.dart';
import '../services/edit_topic_search_service.dart';
import '../services/edit_topic_update_service.dart';
import '../controller/topics_controller.dart';
import '../models/topic_models.dart';
import 'package:calvinlockhart/core/utils/localization/localization_service.dart';

class EditTopicDialog extends StatefulWidget {
  final TopicModel topic;
  final TopicType type;
  final TopicsController controller;

  const EditTopicDialog({
    super.key,
    required this.topic,
    required this.type,
    required this.controller,
  });

  @override
  State<EditTopicDialog> createState() => _EditTopicDialogState();
}

class _EditTopicDialogState extends State<EditTopicDialog> {
  late final TextEditingController topicController;
  final List<PreceptControllers> precepts = [];
  int? selectedDestination;
  bool showError = false;
  bool showDestinationError = false;
  bool showTopicNameError = false;
  bool _isLoading = false;
  final NetworkCaller _caller = NetworkCaller();
  Timer? _debounce;
  List<Map<String, dynamic>> suggestions = [];
  String? selectedTopicId;
  bool _suppressSuggestions = false;

  @override
  void initState() {
    super.initState();
    topicController = TextEditingController(text: widget.topic.title);
    topicController.addListener(_onTopicChanged);

    if (widget.topic.destination != null) {
      switch (widget.topic.destination) {
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
      switch (widget.type) {
        case TopicType.preceptTopics:
          selectedDestination = 0;
          break;
        case TopicType.lessonPrecepts:
          selectedDestination = 1;
          break;
        case TopicType.favorites:
          selectedDestination = 2;
          break;
      }
    }

    for (final precept in widget.topic.precepts) {
      final controllers = PreceptControllers(
        title: TextEditingController(text: precept.reference),
        description: TextEditingController(text: precept.content),
      );
      controllers.title.addListener(() => _onPreceptTitleChanged(controllers));
      precepts.add(controllers);
    }

    if (precepts.isEmpty) {
      final controllers = PreceptControllers(
        title: TextEditingController(),
        description: TextEditingController(),
      );
      controllers.title.addListener(() => _onPreceptTitleChanged(controllers));
      precepts.add(controllers);
    }
  }

  @override
  void dispose() {
    topicController.dispose();
    _debounce?.cancel();
    for (final precept in precepts) {
      precept.dispose();
    }
    super.dispose();
  }

  void _onTopicChanged() {
    if (_suppressSuggestions) return;

    final query = topicController.text.trim();
    if (query.isEmpty) {
      setState(() {
        suggestions.clear();
        selectedTopicId = null;
      });
      return;
    }

    _debounce?.cancel();
    _debounce = Timer(Duration(milliseconds: 300), () async {
      final results = await EditTopicSearchService.searchTopics(query, _caller);
      setState(() {
        suggestions = results;
      });
    });
  }

  void _onPreceptTitleChanged(PreceptControllers controllers) {
    final query = controllers.title.text.trim();
    if (query.isEmpty) {
      setState(() {
        controllers.titleSuggestions.clear();
      });
      return;
    }

    controllers.debounceTimer?.cancel();
    controllers.debounceTimer = Timer(Duration(milliseconds: 300), () {
      EditTopicBibleService.fetchBibleBooks(
        query,
        controllers,
        _caller,
        () => setState(() {}),
      );
    });
  }

  Future<void> _updateTopic() async {
    if (_isLoading) return;

    final topicName = topicController.text.trim();

    final isValid = EditTopicUpdateService.validateTopic(
      topicName: topicName,
      selectedTopicId: selectedTopicId,
      selectedDestination: selectedDestination,
      precepts: precepts,
      onValidationResult:
          (showTopicNameError, showDestinationError, showError) {
            setState(() {
              this.showTopicNameError = showTopicNameError;
              this.showDestinationError = showDestinationError;
              this.showError = showError;
            });
          },
    );

    if (!isValid) return;

    await EditTopicUpdateService.updateTopic(
      context: context,
      topicId: widget.topic.id,
      topicName: topicName,
      selectedTopicId: selectedTopicId,
      selectedDestination: selectedDestination,
      precepts: precepts,
      controller: widget.controller,
      type: widget.type,
      onLoadingStart: () => setState(() => _isLoading = true),
      onLoadingEnd: () => setState(() => _isLoading = false),
    );
  }

  void _addPrecept() {
    setState(() {
      final controllers = PreceptControllers(
        title: TextEditingController(),
        description: TextEditingController(),
      );
      controllers.title.addListener(() => _onPreceptTitleChanged(controllers));
      precepts.add(controllers);
    });
  }

  void _removePrecept(int index) {
    if (precepts.length > 1) {
      setState(() {
        precepts[index].dispose();
        precepts.removeAt(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      LocalizationService.translate('edit_topic'),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _isLoading
                        ? null
                        : () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TopicNameSection(
                      controller: topicController,
                      suggestions: suggestions,
                      enabled: !_isLoading,
                      showTopicNameError: showTopicNameError,
                      onSuggestionSelected: (sugg) {
                        setState(() {
                          _suppressSuggestions = true;
                          topicController.text = sugg['name'] ?? '';
                          selectedTopicId = sugg['id']?.toString();
                          final dest = (sugg['destination'] ?? '').toString();
                          if (dest == 'PRECEPT_TOPIC') {
                            selectedDestination = 0;
                          } else if (dest == 'LESSON_PRECEPTS') {
                            selectedDestination = 1;
                          } else {
                            selectedDestination = 2;
                          }
                          suggestions.clear();
                          _suppressSuggestions = false;
                        });
                      },
                    ),
                    SizedBox(height: 20),
                    DestinationSelectorWidget(
                      selected: selectedDestination,
                      isLoading: _isLoading,
                      onChanged: (val) => setState(() {
                        selectedDestination = val;
                        showDestinationError = false;
                      }),
                    ),
                    SizedBox(height: 20),
                    PreceptsSection(
                      precepts: precepts,
                      isLoading: _isLoading,
                      onAdd: _addPrecept,
                      onRemove: _removePrecept,
                      onPreceptTitleChanged: _onPreceptTitleChanged,
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isLoading
                        ? null
                        : () => Navigator.of(context).pop(),
                    child: Text(
                      LocalizationService.translate('cancel'),
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                  SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _updateTopic,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 18,
                      ),
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Text(LocalizationService.translate('update')),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
