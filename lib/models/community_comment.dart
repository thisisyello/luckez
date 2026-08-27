import 'package:cloud_firestore/cloud_firestore.dart';

class CommunityComment {
  const CommunityComment({
    required this.id,
    required this.content,
    required this.authorId,
    required this.authorName,
    required this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory CommunityComment.fromMap(String id, Map<String, dynamic> map) {
    return CommunityComment(
      id: id,
      content: map['content'] as String? ?? '',
      authorId: map['authorId'] as String? ?? '',
      authorName: map['authorName'] as String? ?? '익명',
      createdAt: _dateTimeFromMapValue(map['createdAt']) ?? DateTime.now(),
      updatedAt: _dateTimeFromMapValue(map['updatedAt']),
      deletedAt: _dateTimeFromMapValue(map['deletedAt']),
    );
  }

  final String id;
  final String content;
  final String authorId;
  final String authorName;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  bool get isDeleted => deletedAt != null;

  static DateTime? _dateTimeFromMapValue(Object? value) {
    if (value == null) {
      return null;
    }

    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    return null;
  }
}
