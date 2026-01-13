import 'package:flutter/material.dart';
import '../models/topic_models.dart';
import '../controller/topics_controller.dart';
import 'note_item_widget.dart';
import 'note_dialogs.dart';
import '../services/topic_notes_service.dart';

class NotesSection extends StatefulWidget {
  final String topicId;
  final TopicType type;
  final TopicsController controller;
  final bool skipLoadNotes;
  final List<NoteModel>? initialNotes;

  const NotesSection({
    super.key,
    required this.topicId,
    required this.type,
    required this.controller,
    this.skipLoadNotes = false,
    this.initialNotes,
  });

  @override
  State<NotesSection> createState() => _NotesSectionState();
}

class _NotesSectionState extends State<NotesSection> {
  List<NoteModel> _notes = [];
  bool _notesLoaded = false;
  bool _loadingNotes = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialNotes != null) {
      _notes = widget.initialNotes!;
      _notesLoaded = true;
    } else if (!widget.skipLoadNotes) {
      _loadNotes();
    }
  }

  Future<void> _loadNotes() async {
    setState(() {
      _loadingNotes = true;
      _notesLoaded = false;
    });

    final notes = await TopicNotesService.loadNotes(widget.topicId);

    setState(() {
      _notes = notes;
      _notesLoaded = true;
      _loadingNotes = false;
    });
  }

  void _showAddNoteDialog() {
    NoteDialogs.showAddNoteDialog(
      context: context,
      onSave: (description) async {
        await widget.controller.createTopicNote(
          widget.topicId,
          description,
          widget.type,
        );
        _loadNotes();
      },
    );
  }

  void _showEditNoteDialog(NoteModel note) {
    NoteDialogs.showEditNoteDialog(
      context: context,
      note: note,
      onSave: (description) async {
        final success = await TopicNotesService.updateNote(
          note.id,
          description,
        );
        if (success) {
          debugPrint('✅ Note updated successfully');
        } else {
          debugPrint('❌ Note update failed');
        }
        await _loadNotes();
      },
    );
  }

  void _deleteNote(String noteId) {
    NoteDialogs.showDeleteNoteDialog(
      context: context,
      onConfirm: () async {
        await widget.controller.deleteTopicNote(
          noteId,
          widget.type,
          widget.topicId,
        );
        _loadNotes();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(
      '🔧 Building notes section for topic "${widget.topicId}" with ${_notes.length} notes (loaded: $_notesLoaded, loading: $_loadingNotes)',
    );

    if (_loadingNotes) {
      return _buildLoadingState();
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(0xFFF0F8FF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Color(0xFF00228E), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildNotesHeader(),
          SizedBox(height: 8),
          if (_notes.isEmpty)
            _buildEmptyState()
          else
            ..._notes.map(
              (note) => NoteItemWidget(
                note: note,
                onEdit: () => _showEditNoteDialog(note),
                onDelete: () => _deleteNote(note.id),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(0xFFF0F8FF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Color(0xFF00228E), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Notes:',
                style: TextStyle(
                  color: Color(0xFF21252C),
                  fontSize: 18,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w500,
                  height: 1.50,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF00228E),
                        ),
                      ),
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Loading...',
                      style: TextStyle(
                        color: Color(0xFF00228E),
                        fontSize: 12,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotesHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Notes:',
          style: TextStyle(
            color: Color(0xFF21252C),
            fontSize: 18,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w500,
            height: 1.50,
          ),
        ),
        GestureDetector(
          onTap: _showAddNoteDialog,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Color(0xFF00228E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, size: 14, color: Colors.white),
                SizedBox(width: 4),
                Text(
                  'Add Note',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Color(0xFFE6E9F4)),
      ),
      child: Text(
        'No notes yet. Tap "Add Note" to create your first note.',
        style: TextStyle(
          color: Color(0xFF898F9B),
          fontSize: 14,
          fontFamily: 'Roboto',
          fontWeight: FontWeight.w400,
          fontStyle: FontStyle.italic,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
