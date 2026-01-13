import 'package:flutter/material.dart';
import '../models/topic_models.dart';
import '../controller/topics_controller.dart';
import 'note_item_widget.dart';
import 'note_dialogs.dart';
import '../services/topic_notes_service.dart';

class PreceptNotesSection extends StatefulWidget {
  final String preceptId;
  final List<NoteModel> initialNotes;
  final TopicType type;
  final TopicsController controller;
  final bool showAddNote;

  const PreceptNotesSection({
    super.key,
    required this.preceptId,
    required this.initialNotes,
    required this.type,
    required this.controller,
    this.showAddNote = true,
  });

  @override
  State<PreceptNotesSection> createState() => _PreceptNotesSectionState();
}

class _PreceptNotesSectionState extends State<PreceptNotesSection> {
  late List<NoteModel> _notes;

  @override
  void initState() {
    super.initState();
    _notes = List<NoteModel>.from(widget.initialNotes);
  }

  @override
  void didUpdateWidget(PreceptNotesSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialNotes != widget.initialNotes) {
      _notes = List<NoteModel>.from(widget.initialNotes);
    }
  }

  void _refreshNotes() {
    final updatedNotes = widget.controller.getPreceptNotesFor(
      widget.preceptId,
      widget.type,
    );
    setState(() {
      _notes = List<NoteModel>.from(updatedNotes);
    });
  }

  void _showAddNoteDialog() {
    NoteDialogs.showAddNoteDialog(
      context: context,
      onSave: (description) async {
        await widget.controller.createPreceptNote(
          widget.preceptId,
          description,
          widget.type,
        );
        // Refresh notes after creating
        Future.delayed(Duration(milliseconds: 500), _refreshNotes);
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
          // Refresh notes after updating
          _refreshNotes();
        } else {
          debugPrint('❌ Note update failed');
        }
      },
    );
  }

  void _deleteNote(String noteId) {
    NoteDialogs.showDeleteNoteDialog(
      context: context,
      onConfirm: () async {
        await widget.controller.deletePreceptNote(
          noteId,
          widget.type,
          widget.preceptId,
        );
        // Refresh notes after deleting
        Future.delayed(Duration(milliseconds: 500), _refreshNotes);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12),
      margin: EdgeInsets.only(top: 12),
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

  Widget _buildNotesHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Notes:',
          style: TextStyle(
            color: Color(0xFF21252C),
            fontSize: 16,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w500,
            height: 1.50,
          ),
        ),
        if (widget.showAddNote)
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
}
