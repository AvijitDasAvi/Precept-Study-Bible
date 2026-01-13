class NoteModel {
  final String id;
  final String preceptId;
  final String description;
  final String createdAt;
  final String updatedAt;

  NoteModel({
    required this.id,
    required this.preceptId,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  static NoteModel fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'] ?? '',
      preceptId: json['preceptId'] ?? '',
      description: json['description'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'preceptId': preceptId,
      'description': description,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  NoteModel copyWith({
    String? id,
    String? preceptId,
    String? description,
    String? createdAt,
    String? updatedAt,
  }) {
    return NoteModel(
      id: id ?? this.id,
      preceptId: preceptId ?? this.preceptId,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class TopicModel {
  final String id;
  final String title;
  final String createdAt;
  final String? destination;
  final List<PreceptModel> precepts;

  TopicModel({
    required this.id,
    required this.title,
    required this.createdAt,
    this.destination,
    required this.precepts,
  });

  static TopicModel fromJson(Map<String, dynamic> json) {
    return TopicModel(
      id: json['id'] ?? '',
      title: json['name'] ?? json['title'] ?? '', // API uses 'name' field
      createdAt: json['createdAt'] ?? '',
      destination: json['destination'],
      precepts:
          (json['precepts'] as List?)
              ?.map((p) => PreceptModel.fromJson(p))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': title, // API expects 'name' field
      'createdAt': createdAt,
      'destination': destination,
      'precepts': precepts.map((p) => p.toJson()).toList(),
    };
  }

  TopicModel copyWith({
    String? id,
    String? title,
    String? createdAt,
    String? destination,
    List<PreceptModel>? precepts,
  }) {
    return TopicModel(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      destination: destination ?? this.destination,
      precepts: precepts ?? this.precepts,
    );
  }
}

class PreceptModel {
  final String id;
  final String reference;
  final String content;
  final bool isExpanded;
  final List<NoteModel> notes;

  PreceptModel({
    required this.id,
    required this.reference,
    required this.content,
    this.isExpanded = false,
    this.notes = const [],
  });

  static PreceptModel fromJson(Map<String, dynamic> json) {
    // The backend recently changed the precept shape: it may now return
    // objects without an 'id' and with a 'contents' array (List<String>)
    // instead of a single 'content' string. We handle both formats here.

    // Use provided id if present, otherwise fall back to reference so
    // downstream code that relies on precept.id still works.
    final id = json['id'] ?? json['reference'] ?? '';

    final reference = json['reference'] ?? '';

    // Build a single content string. Prefer explicit 'content' if present,
    // otherwise join the 'contents' array with double newlines to preserve
    // paragraph breaks.
    String content = '';
    if (json['content'] != null && json['content'] is String) {
      content = json['content'];
    } else if (json['contents'] is List) {
      try {
        content = (json['contents'] as List).map((e) => e?.toString() ?? '').join('\n\n');
      } catch (e) {
        content = '';
      }
    } else {
      content = '';
    }

    final isExpanded = json['isExpanded'] ?? false;

    // Notes from backend might come as a list of objects or list of strings.
    final notesJson = json['notes'] as List?;
    final notes = (notesJson ?? [])
        .map<NoteModel>((n) {
      if (n == null) return NoteModel.fromJson({});
      if (n is Map<String, dynamic>) {
        return NoteModel.fromJson(n);
      }
      // If the note is a plain string, create a minimal NoteModel using the
      // string as the description.
      return NoteModel(
        id: '',
        preceptId: '',
        description: n.toString(),
        createdAt: '',
        updatedAt: '',
      );
    }).toList();

    return PreceptModel(
      id: id,
      reference: reference,
      content: content,
      isExpanded: isExpanded,
      notes: notes,
    );
  }

  Map<String, dynamic> toJson() {
    // When sending back to the API, prefer the newer shape: 'contents' as
    // a list of paragraphs. We also keep 'content' for backward
    // compatibility.
    final contents = content.isEmpty
        ? []
        : content.split('\n\n').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();

    return {
      if (id.isNotEmpty) 'id': id,
      'reference': reference,
      'content': content,
      'contents': contents,
      'isExpanded': isExpanded,
      'notes': notes.map((n) => n.toJson()).toList(),
    };
  }

  PreceptModel copyWith({
    String? id,
    String? reference,
    String? content,
    bool? isExpanded,
    List<NoteModel>? notes,
  }) {
    return PreceptModel(
      id: id ?? this.id,
      reference: reference ?? this.reference,
      content: content ?? this.content,
      isExpanded: isExpanded ?? this.isExpanded,
      notes: notes ?? this.notes,
    );
  }
}

class VerseModel {
  final String reference;
  final String text;

  VerseModel({required this.reference, required this.text});

  static VerseModel fromJson(Map<String, dynamic> json) {
    return VerseModel(
      reference: json['reference'] ?? '',
      text: json['text'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'reference': reference, 'text': text};
  }
}

enum TopicType { preceptTopics, lessonPrecepts, favorites }
