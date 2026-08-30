import 'package:cloud_firestore/cloud_firestore.dart';

class CommunityLikedPost {
  const CommunityLikedPost({
    required this.postId,
    required this.title,
    required this.authorName,
    required this.likedAt,
    this.postCreatedAt,
  });

  factory CommunityLikedPost.fromMap(String id, Map<String, dynamic> map) {
    return CommunityLikedPost(
      postId: map['postId'] as String? ?? id,
      title: map['title'] as String? ?? '제목 없음',
      authorName: map['authorName'] as String? ?? '익명',
      likedAt: _dateTimeFromMapValue(map['likedAt']) ?? DateTime.now(),
      postCreatedAt: _dateTimeFromMapValue(map['postCreatedAt']),
    );
  }

  final String postId;
  final String title;
  final String authorName;
  final DateTime likedAt;
  final DateTime? postCreatedAt;

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
