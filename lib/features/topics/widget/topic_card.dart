import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/topic_models.dart';
import '../controller/topics_controller.dart';
import 'topic_menu_widget.dart';
import 'precept_item_widget.dart';
import 'topic_card_header.dart';
import '../../home/widget/add_topic_dialog.dart';

class TopicCard extends StatefulWidget {
  final TopicModel topic;
  final TopicType type;
  final TopicsController controller;
  final VoidCallback? onDelete;
  final bool showAddPrecepts;
  final bool showAddNote;
  final bool isDarkMode;

  const TopicCard({
    super.key,
    required this.topic,
    required this.type,
    required this.controller,
    this.onDelete,
    this.showAddPrecepts = true,
    this.showAddNote = true,
    required this.isDarkMode,
  });

  @override
  State<TopicCard> createState() => _TopicCardState();
}

class _TopicCardState extends State<TopicCard> {
  bool _showMenu = false;
  bool _isExpanded = false;
  List<PreceptModel>? _localPrecepts;
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  @override
  void initState() {
    super.initState();
    _localPrecepts = List<PreceptModel>.from(widget.topic.precepts);
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _toggleMenu() {
    if (_showMenu) {
      _removeOverlay();
    } else {
      _showOverlay();
    }
    setState(() {
      _showMenu = !_showMenu;
    });
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showOverlay() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(
      builder: (context) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          _removeOverlay();
          setState(() {
            _showMenu = false;
          });
        },
        child: Stack(
          children: [
            Positioned(
              // width: 140,
              child: CompositedTransformFollower(
                link: _layerLink,
                showWhenUnlinked: false,
                offset: Offset(0, 54),
                child: Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: EdgeInsets.only(right: 16),
                    child: Material(
                      elevation: 16,
                      borderRadius: BorderRadius.circular(12),
                      shadowColor: Colors.black.withValues(alpha: 0.3),
                      child: TweenAnimationBuilder<double>(
                        duration: Duration(milliseconds: 200),
                        tween: Tween(begin: 0.0, end: 1.0),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: 0.8 + (0.2 * value),
                            alignment: Alignment.topRight,
                            child: Opacity(
                              opacity: value,
                              child: TopicMenuWidget(
                                topic: widget.topic,
                                type: widget.type,
                                controller: widget.controller,
                                notes: [],
                                onMenuClose: () {
                                  _removeOverlay();
                                  setState(() {
                                    _showMenu = false;
                                  });
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TopicsController>(
      builder: (controller) {
        final cardBgColor = widget.isDarkMode ? Colors.grey[900] : Colors.white;
        final borderColor = widget.isDarkMode
            ? Colors.grey[800]
            : Color(0xFFE6E9F4);
        final shadowColor =
            (widget.isDarkMode ? Colors.black : Color(0x33B0CDEC)).withValues(
              alpha: 0.3,
            );

        return GestureDetector(
          onTap: () {
            if (_showMenu) {
              _removeOverlay();
              setState(() {
                _showMenu = false;
              });
            } else {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            }
          },
          child: Container(
            width: double.infinity,
            margin: EdgeInsets.symmetric(vertical: 8),
            child: CompositedTransformTarget(
              link: _layerLink,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: ShapeDecoration(
                  color: cardBgColor,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      width: 1,
                      color: borderColor ?? Colors.transparent,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  shadows: [
                    BoxShadow(
                      color: shadowColor,
                      blurRadius: 20,
                      offset: Offset(0, 1),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TopicCardHeader(
                            topic: widget.topic,
                            type: widget.type,
                            controller: widget.controller,
                            onDelete: widget.onDelete,
                            onMenuTap: _toggleMenu,
                            showMenu: _showMenu,
                            isDarkMode: widget.isDarkMode,
                          ),
                        ),
                        Icon(
                          _isExpanded ? Icons.expand_less : Icons.expand_more,
                          color: widget.isDarkMode
                              ? Colors.grey[400]
                              : Colors.grey[600],
                          size: 24,
                        ),
                      ],
                    ),
                    if (_isExpanded) ...[
                      SizedBox(height: 10),
                      Divider(
                        color: widget.isDarkMode
                            ? Colors.grey[800]
                            : Color(0xFFEDEEF0),
                        height: 1,
                      ),
                      SizedBox(height: 10),
                      _buildPreceptsList(),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPreceptsList() {
    // Get the latest topic data from the controller based on type
    TopicModel? currentTopic;

    switch (widget.type) {
      case TopicType.preceptTopics:
        currentTopic = widget.controller.preceptTopics.firstWhereOrNull(
          (t) => t.id == widget.topic.id,
        );
        break;
      case TopicType.lessonPrecepts:
        currentTopic = widget.controller.lessonPrecepts.firstWhereOrNull(
          (t) => t.id == widget.topic.id,
        );
        break;
      case TopicType.favorites:
        currentTopic = widget.controller.favorites.firstWhereOrNull(
          (t) => t.id == widget.topic.id,
        );
        break;
    }

    final list = currentTopic?.precepts ?? widget.topic.precepts;

    return Column(
      children: [
        ...list.map((precept) {
          return PreceptItemWidget(
            precept: precept,
            topicId: widget.topic.id,
            type: widget.type,
            controller: widget.controller,
            showAddNote: widget.showAddNote,
            isDarkMode: widget.isDarkMode,
            onToggleExpansion: () {
              widget.controller.togglePreceptExpansion(
                widget.topic.id,
                precept.id,
                widget.type,
              );
              if (_localPrecepts != null) {
                final idx = _localPrecepts!.indexWhere(
                  (p) => p.id == precept.id,
                );
                if (idx != -1) {
                  final p = _localPrecepts![idx];
                  _localPrecepts![idx] = p.copyWith(isExpanded: !p.isExpanded);
                  setState(() {});
                }
              }
            },
          );
        }),
        SizedBox(height: 8),
        if (widget.showAddPrecepts)
          GestureDetector(
            onTap: () {
              // Determine destination index based on type
              int destinationIndex = 0;
              if (widget.type == TopicType.lessonPrecepts) {
                destinationIndex = 1;
              } else if (widget.type == TopicType.favorites) {
                destinationIndex = 2;
              }

              showDialog(
                context: context,
                builder: (context) => Dialog(
                  insetPadding: EdgeInsets.all(16),
                  child: AddTopicDialog(
                    initialTopicName: widget.topic.title,
                    initialDestination: destinationIndex,
                    initialTopicId: widget.topic.id,
                  ),
                ),
              );
            },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: widget.isDarkMode ? Colors.grey[800] : Color(0xFFE6E9F4),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, color: Color(0xFF334EA5), size: 18),
                  SizedBox(width: 6),
                  Text(
                    'Add Precepts',
                    style: TextStyle(
                      color: Color(0xFF334EA5),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
