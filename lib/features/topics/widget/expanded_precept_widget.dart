import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/topic_models.dart';
import '../controller/topics_controller.dart';
import 'precept_notes_section.dart';

class _Occurrence {
  final String token;
  final int start;
  _Occurrence(this.token, this.start);
}

class ExpandedPreceptWidget extends StatefulWidget {
  final PreceptModel precept;
  final String topicId;
  final TopicType type;
  final TopicsController controller;
  final bool showAddNote;
  final bool isDarkMode;

  const ExpandedPreceptWidget({
    super.key,
    required this.precept,
    required this.topicId,
    required this.type,
    required this.controller,
    this.showAddNote = true,
    required this.isDarkMode,
  });

  @override
  State<ExpandedPreceptWidget> createState() => _ExpandedPreceptWidgetState();
}

class _ExpandedPreceptWidgetState extends State<ExpandedPreceptWidget> {
  final Map<String, String> _replacements = {};

  // Mapping of special words to their replacement options
  static const Map<String, List<String>> wordReplacements = {
    'LORD': ['LORD', 'Ahayah', 'Yashaya', 'Alahayam', 'Power', 'Most High'],
    'lord': ['lord', 'Ahayah', 'Yashaya', 'Alahayam', 'Power', 'Most High'],
    'Lord': ['Lord', 'Ahayah', 'Yashaya', 'Alahayam', 'Power', 'Most High'],
    'GOD': ['GOD', 'Ahayah', 'Yashaya', 'Alahayam', 'Power', 'Most High'],
    'god': ['god', 'Ahayah', 'Yashaya', 'Alahayam', 'Power', 'Most High'],
    'God': ['God', 'Ahayah', 'Yashaya', 'Alahayam', 'Power', 'Most High'],
    'JEHOVAH': ['JEHOVAH', 'Ahayah'],
    'jehovah': ['jehovah', 'Ahayah'],
    'Jehovah': ['Jehovah', 'Ahayah'],
    'Holy': ['Holy', 'Quadash'],
    'holy': ['holy', 'Quadash'],
    'HOLY': ['HOLY', 'Quadash'],
    'Spirit': ['Spirit', 'Ruach'],
    'spirit': ['spirit', 'Ruach'],
    'SPIRIT': ['SPIRIT', 'Ruach'],
    'Jesus': ['Jesus', 'Yashaya'],
    'jesus': ['jesus', 'Yashaya'],
    'JESUS': ['JESUS', 'Yashaya'],
    'Ghost': ['Ghost', 'Ruach', 'Spirit'],
    'ghost': ['ghost', 'Ruach', 'Spirit'],
    'GHOST': ['GHOST', 'Ruach', 'Spirit'],
  };

  @override
  void initState() {
    super.initState();
    _loadReplacements();
  }

  String _prefsKeyFor(String token, int start) {
    return 'topic_precept_replace_${widget.topicId}_${widget.precept.id}_${start}_$token';
  }

  Future<void> _loadReplacements() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final occs = _detectOccurrences(widget.precept.content);
      for (final occ in occs) {
        final key = _prefsKeyFor(occ.token, occ.start);
        final v = prefs.getString(key);
        if (v != null && v.isNotEmpty) {
          _replacements['${occ.token}@${occ.start}'] = v;
        }
      }
      if (mounted) setState(() {});
    } catch (_) {}
  }

  Future<void> _saveReplacement(
    String token,
    int start,
    String replacement,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _prefsKeyFor(token, start);
      await prefs.setString(key, replacement);
      _replacements['$token@$start'] = replacement;
      if (mounted) setState(() {});
    } catch (_) {}
  }

  List<_Occurrence> _detectOccurrences(String text) {
    final occs = <_Occurrence>[];
    final quoteReg = RegExp(r'"([^"]+)"');
    // Match special words case-insensitively
    final specialWords = RegExp(
      r'\b(LORD|Lord|lord|GOD|God|god|JEHOVAH|Jehovah|jehovah|Holy|holy|HOLY|Spirit|spirit|SPIRIT|Jesus|jesus|JESUS|Ghost|ghost|GHOST)\b',
    );

    for (final m in quoteReg.allMatches(text)) {
      final tok = m.group(1)!.trim();
      final startIndex = m.start + 1;
      occs.add(_Occurrence(tok, startIndex));
    }
    for (final m in specialWords.allMatches(text)) {
      final tok = m.group(0)!.trim();
      occs.add(_Occurrence(tok, m.start));
    }
    occs.sort((a, b) => a.start.compareTo(b.start));
    return occs;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPreceptContent(),
          SizedBox(height: 12),
          PreceptNotesSection(
            preceptId: widget.precept.id,
            initialNotes: widget.precept.notes,
            type: widget.type,
            controller: widget.controller,
            showAddNote: widget.showAddNote,
          ),
          // _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildPreceptContent() {
    final textColor = widget.isDarkMode ? Colors.white : Color(0xFF2B303A);
    final text = widget.precept.content;
    final occs = _detectOccurrences(text);
    if (occs.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w400,
            height: 1.50,
          ),
        ),
      );
    }

    final startMap = <int, _Occurrence>{};
    for (final o in occs) {
      startMap[o.start] = o;
    }

    final spans = <InlineSpan>[];
    int idx = 0;
    while (idx < text.length) {
      final occ = startMap[idx];
      if (occ != null) {
        final token = occ.token;
        final key = '$token@${occ.start}';
        final replacement = _replacements[key] ?? token;
        spans.add(
          WidgetSpan(
            child: GestureDetector(
              onTapDown: (e) async {
                final options =
                    wordReplacements[token] ??
                    [token, 'Ahayah', 'Yashaya', 'Alahayam'];
                final chosen = await showMenu<String?>(
                  context: context,
                  position: RelativeRect.fromLTRB(
                    e.globalPosition.dx,
                    e.globalPosition.dy,
                    e.globalPosition.dx + 1,
                    e.globalPosition.dy + 1,
                  ),
                  items: options
                      .map<PopupMenuEntry<String>>(
                        (o) => PopupMenuItem<String>(value: o, child: Text(o)),
                      )
                      .toList(),
                );
                if (chosen != null) {
                  await _saveReplacement(token, occ.start, chosen);
                }
              },
              child: Text(
                replacement,
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  height: 1.50,
                ),
              ),
            ),
          ),
        );
        idx += token.length;
      } else {
        spans.add(
          TextSpan(
            text: text[idx],
            style: TextStyle(color: textColor, fontSize: 16, height: 1.50),
          ),
        );
        idx++;
      }
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 8),
      child: RichText(text: TextSpan(children: spans)),
    );
  }

  // Widget _buildActionButtons() {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //     children: [
  //       Expanded(
  //         child: Row(
  //           children: [
  //             Text(
  //               'Add Precept',
  //               style: TextStyle(
  //                 color: Color(0xFF00228E),
  //                 fontSize: 14,
  //                 fontFamily: 'Roboto',
  //                 fontWeight: FontWeight.w600,
  //                 height: 1.50,
  //               ),
  //             ),
  //             SizedBox(width: 4),
  //             Container(
  //               width: 20,
  //               height: 20,
  //               decoration: BoxDecoration(shape: BoxShape.circle),
  //               child: Icon(Icons.add, size: 16, color: Color(0xFF00228E)),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ],
  //   );
  // }
}
