import 'package:flutter/material.dart';
import '../models/topic_models.dart';
import '../../../core/datetime_format.dart';

class NoteItemWidget extends StatelessWidget {
  final NoteModel note;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const NoteItemWidget({
    super.key,
    required this.note,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Color(0xFFE6E9F4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  note.description,
                  style: TextStyle(
                    color: Color(0xFF2B303A),
                    fontSize: 14,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w400,
                    height: 1.50,
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: onEdit,
                    child: Icon(Icons.edit, size: 16, color: Color(0xFF898F9B)),
                  ),
                  SizedBox(width: 8),
                  GestureDetector(
                    onTap: onDelete,
                    child: Icon(
                      Icons.delete,
                      size: 16,
                      color: Color(0xFFDA5963),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            DatetimeFormat.formatUtcToLocal(note.createdAt),
            style: TextStyle(
              color: Color(0xFF898F9B),
              fontSize: 12,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
