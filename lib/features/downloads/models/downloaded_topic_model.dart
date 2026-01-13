import 'dart:convert';

class DownloadedTopicModel {
  final String id;
  final String title;
  final String createdAt;
  final List<Map<String, dynamic>> precepts;
  final List<Map<String, dynamic>> notes;

  DownloadedTopicModel({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.precepts,
    required this.notes,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'createdAt': createdAt,
    'precepts': precepts,
    'notes': notes,
  };

  factory DownloadedTopicModel.fromJson(Map<String, dynamic> json) =>
      DownloadedTopicModel(
        id: json['id'].toString(),
        title: json['title'] ?? '',
        createdAt: json['createdAt'] ?? '',
        precepts: (json['precepts'] as List? ?? [])
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList(),
        notes: (json['notes'] as List? ?? [])
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList(),
      );

  String encode() => json.encode(toJson());

  static DownloadedTopicModel decode(String encoded) =>
      DownloadedTopicModel.fromJson(
        json.decode(encoded) as Map<String, dynamic>,
      );
}
