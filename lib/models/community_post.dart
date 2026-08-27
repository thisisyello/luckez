import 'package:cloud_firestore/cloud_firestore.dart';

class CommunityPost {
  const CommunityPost({
    required this.id,
    required this.title,
    required this.content,
    required this.authorId,
    required this.authorName,
    required this.commentCount,
    required this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory CommunityPost.fromMap(String id, Map<String, dynamic> map) {
    return CommunityPost(
      id: id,
      title: map['title'] as String? ?? '',
      content: map['content'] as String? ?? '',
      authorId: map['authorId'] as String? ?? '',
      authorName: map['authorName'] as String? ?? '익명',
      commentCount: map['commentCount'] as int? ?? 0,
      createdAt: _dateTimeFromMapValue(map['createdAt']) ?? DateTime.now(),
      updatedAt: _dateTimeFromMapValue(map['updatedAt']),
      deletedAt: _dateTimeFromMapValue(map['deletedAt']),
    );
  }

  final String id;
  final String title;
  final String content;
  final String authorId;
  final String authorName;
  final int commentCount;
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
