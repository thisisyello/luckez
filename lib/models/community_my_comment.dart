import 'package:cloud_firestore/cloud_firestore.dart';

class CommunityMyComment {
  const CommunityMyComment({
    required this.commentId,
    required this.postId,
    required this.postTitle,
    required this.content,
    required this.createdAt,
    this.deletedAt,
  });

  factory CommunityMyComment.fromMap(String id, Map<String, dynamic> map) {
    return CommunityMyComment(
      commentId: map['commentId'] as String? ?? id,
      postId: map['postId'] as String? ?? '',
      postTitle: map['postTitle'] as String? ?? '제목 없음',
      content: map['content'] as String? ?? '',
      createdAt: _dateTimeFromMapValue(map['createdAt']) ?? DateTime.now(),
      deletedAt: _dateTimeFromMapValue(map['deletedAt']),
    );
  }

  final String commentId;
  final String postId;
  final String postTitle;
  final String content;
  final DateTime createdAt;
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
