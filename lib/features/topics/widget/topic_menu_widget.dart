import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:calvinlockhart/core/utils/localization/localization_service.dart';
import '../../downloads/controller/downloads_controller.dart';
import '../../downloads/models/downloaded_topic_model.dart';
import '../models/topic_models.dart';
import '../controller/topics_controller.dart';
import '../../home/widget/add_topic_dialog.dart';

class TopicMenuWidget extends StatelessWidget {
  final TopicModel topic;
  final TopicType type;
  final TopicsController controller;
  final VoidCallback onMenuClose;
  final List<NoteModel>? notes;

  const TopicMenuWidget({
    super.key,
    required this.topic,
    required this.type,
    required this.controller,
    required this.onMenuClose,
    this.notes,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 20,
              offset: Offset(0, 8),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 8,
              offset: Offset(0, 2),
              spreadRadius: 0,
            ),
          ],
          border: Border.all(color: Color(0xFFE5E7EB), width: 1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildMenuItem(
                Icons.share_outlined,
                LocalizationService.translate('share'),
                () {
                  final RenderBox? box =
                      context.findRenderObject() as RenderBox?;
                  final Rect shareRect = box != null
                      ? box.localToGlobal(Offset.zero) & box.size
                      : Rect.fromLTWH(0, 0, 100, 100);
                  controller.shareTopic(topic, sharePositionOrigin: shareRect);
                  onMenuClose();
                },
              ),
              _buildDivider(),
              _buildMenuItem(
                Icons.download_outlined,
                LocalizationService.translate('download'),
                () async {
                  final dCtrl = Get.isRegistered<DownloadsController>()
                      ? Get.find<DownloadsController>()
                      : Get.put(DownloadsController(), permanent: true);
                  final precepts = topic.precepts
                      .map(
                        (p) => {
                          'id': p.id,
                          'reference': p.reference,
                          'content': p.content,
                        },
                      )
                      .toList();
                  final notesList = (notes ?? [])
                      .map((n) => n.toJson())
                      .toList();
                  final saveId = (topic.id.isNotEmpty)
                      ? topic.id
                      : '${topic.title}@${topic.createdAt}@${DateTime.now().millisecondsSinceEpoch}';
                  final downloaded = DownloadedTopicModel(
                    id: saveId,
                    title: topic.title,
                    createdAt: topic.createdAt,
                    precepts: precepts.cast<Map<String, dynamic>>(),
                    notes: notesList.cast<Map<String, dynamic>>(),
                  );
                  await dCtrl.downloadTopic(downloaded);
                  EasyLoading.showSuccess(
                    LocalizationService.translate('topic_saved_offline'),
                  );
                  debugPrint(
                    '💾 Downloaded topic saved with id: ${downloaded.id}',
                  );
                  try {
                    final prefs = await SharedPreferences.getInstance();
                    final raw =
                        prefs.getStringList('downloaded_topics_v1') ?? [];
                    debugPrint(
                      '💾 SharedPreferences now contains ${raw.length} downloaded entries',
                    );
                  } catch (e) {
                    debugPrint('💾 Could not read prefs after saving: $e');
                  }
                  onMenuClose();
                },
              ),
              _buildDivider(),
              _buildMenuItem(
                Icons.edit_outlined,
                LocalizationService.translate('edit'),
                () {
                  _showEditTopicDialog(context);
                  onMenuClose();
                },
              ),
              _buildDivider(),
              _buildMenuItem(
                Icons.delete_outline,
                LocalizationService.translate('delete'),
                () {
                  onMenuClose();
                  _showDeleteConfirmation(context);
                },
                isDelete: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String text,
    VoidCallback onTap, {
    bool isDelete = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        hoverColor: isDelete ? Color(0xFFFEF2F2) : Color(0xFFF9FAFB),
        splashColor: isDelete ? Color(0xFFFECECE) : Color(0xFFE5E7EB),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: isDelete ? Color(0xFFDC2626) : Color(0xFF6B7280),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    color: isDelete ? Color(0xFFDC2626) : Color(0xFF374151),
                    fontSize: 14,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w500,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      width: double.infinity,
      color: Color(0xFFF3F4F6),
    );
  }

  void _showEditTopicDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: EdgeInsets.all(16),
        child: AddTopicDialog(
          topicToEdit: topic,
          editingTopicType: type,
          editingTopicController: controller,
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return _DeleteConfirmationDialog(
          topic: topic,
          type: type,
          controller: controller,
          onMenuClose: onMenuClose,
        );
      },
    );
  }
}

class _DeleteConfirmationDialog extends StatefulWidget {
  final TopicModel topic;
  final TopicType type;
  final TopicsController controller;
  final VoidCallback onMenuClose;

  const _DeleteConfirmationDialog({
    required this.topic,
    required this.type,
    required this.controller,
    required this.onMenuClose,
  });

  @override
  State<_DeleteConfirmationDialog> createState() =>
      _DeleteConfirmationDialogState();
}

class _DeleteConfirmationDialogState extends State<_DeleteConfirmationDialog> {
  bool isDeleting = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626), size: 24),
          SizedBox(width: 8),
          Text(
            LocalizationService.translate('delete_topic'),
            style: TextStyle(
              color: Color(0xFF111827),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      content: Text(
        '${LocalizationService.translate('delete_topic_confirmation')} "${widget.topic.title}" ${LocalizationService.translate('delete_topic_cannot_undo')}',
        style: TextStyle(color: Color(0xFF6B7280), fontSize: 14, height: 1.4),
      ),
      actions: [
        TextButton(
          onPressed: isDeleting
              ? null
              : () {
                  Navigator.of(context).pop();
                },
          style: TextButton.styleFrom(
            foregroundColor: Color(0xFF6B7280),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: Text(
            LocalizationService.translate('cancel'),
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        FilledButton(
          onPressed: isDeleting
              ? null
              : () async {
                  setState(() => isDeleting = true);
                  try {
                    await widget.controller.deleteTopic(
                      widget.topic.id,
                      widget.type,
                    );
                    Navigator.of(context).pop();
                  } catch (e) {
                    setState(() => isDeleting = false);
                    debugPrint('Error deleting topic: $e');
                  }
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFDC2626),
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isDeleting) ...[
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  '${LocalizationService.translate('deleting')}...',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ] else
                Text(
                  LocalizationService.translate('delete'),
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
