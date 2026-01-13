import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../all_bibles/controller/all_bibles_controller.dart';

class _Occurrence {
  final String token;
  final int start;
  _Occurrence(this.token, this.start);
}

class BibleChapterParagraphItem extends StatefulWidget {
  final Book? book;
  final int? chapter;
  final String paragraph;
  final int index;
  final bool isSelected;
  final GlobalKey? paraKey;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onAddPressed;
  final bool isDarkMode;

  const BibleChapterParagraphItem({
    super.key,
    this.book,
    this.chapter,
    required this.paragraph,
    required this.index,
    required this.isSelected,
    this.paraKey,
    required this.onTap,
    this.onLongPress,
    this.onAddPressed,
    required this.isDarkMode,
  });

  @override
  State<BibleChapterParagraphItem> createState() =>
      _BibleChapterParagraphItemState();
}

class _BibleChapterParagraphItemState extends State<BibleChapterParagraphItem> {
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
    final bookId = widget.book?.id ?? 'unknown';
    final chap = widget.chapter?.toString() ?? '0';
    return 'name_replace_${bookId}_${chap}_${widget.index}_${start}_$token';
  }

  Future<void> _loadReplacements() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final occs = _detectOccurrences(widget.paragraph);
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

  void _showReplacementMenu(
    BuildContext context,
    Offset position,
    String token,
    int start,
  ) async {
    // Get replacement options for the token, fallback to token + generic options if not found
    List<String> options =
        wordReplacements[token] ?? [token, 'Ahayah', 'Yashaya', 'Alahayam'];

    final chosen = await showMenu<String?>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx + 1,
        position.dy + 1,
      ),
      items: options
          .map((o) => PopupMenuItem(value: o, child: Text(o)))
          .toList(),
    );
    if (chosen != null) {
      await _saveReplacement(token, start, chosen);
    }
  }

  List<InlineSpan> _buildSpans(String text) {
    final occs = _detectOccurrences(text);
    if (occs.isEmpty) return [TextSpan(text: text)];

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
              onTapDown: (e) => _showReplacementMenu(
                context,
                e.globalPosition,
                token,
                occ.start,
              ),
              child: Text(
                replacement,
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        );
        idx += token.length;
      } else {
        spans.add(TextSpan(text: text[idx]));
        idx++;
      }
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final textColor = widget.isDarkMode ? Colors.white : Color(0xFF383E4B);
    final containerBgColor = widget.isSelected
        ? (widget.isDarkMode ? Colors.grey[850] : Color(0xFFEDEEF0))
        : (widget.isDarkMode ? Colors.grey[900] : Colors.white);
    final numberColor = widget.isSelected
        ? Color(0xFFE701BD)
        : (widget.isDarkMode ? Colors.grey[400] : Color(0xFF383E4B));

    final textStyle = TextStyle(color: textColor, fontSize: 16);
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: Container(
        key: widget.paraKey,
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: containerBgColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.index + 1}',
              style: TextStyle(
                color: numberColor,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SelectableText.rich(
                    TextSpan(
                      style: textStyle,
                      children: _buildSpans(widget.paragraph),
                    ),
                  ),
                  if (widget.isSelected)
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        onPressed: widget.onAddPressed ?? () {},
                        icon: Icon(Icons.add_circle, color: Color(0xFF00228E)),
                      ),
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
