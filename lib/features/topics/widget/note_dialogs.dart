import 'package:flutter/material.dart';
import '../models/topic_models.dart';

class NoteDialogs {
  static void showAddNoteDialog({
    required BuildContext context,
    required Function(String description) onSave,
  }) {
    final TextEditingController noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Note'),
        content: TextField(
          controller: noteController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Enter your note...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (noteController.text.trim().isNotEmpty) {
                Navigator.pop(context);
                onSave(noteController.text.trim());
              }
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  static void showEditNoteDialog({
    required BuildContext context,
    required NoteModel note,
    required Function(String description) onSave,
  }) {
    final TextEditingController noteController = TextEditingController(
      text: note.description,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Note'),
        content: TextField(
          controller: noteController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Enter your note...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (noteController.text.trim().isNotEmpty) {
                debugPrint('🔄 Editing note with ID: ${note.id}');
                debugPrint('🔄 New description: ${noteController.text.trim()}');

                Navigator.pop(context);
                onSave(noteController.text.trim());
              }
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  static void showDeleteNoteDialog({
    required BuildContext context,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Note'),
        content: Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            style: TextButton.styleFrom(foregroundColor: Color(0xFFDA5963)),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }
}
