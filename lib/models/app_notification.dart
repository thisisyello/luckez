import 'package:cloud_firestore/cloud_firestore.dart';

enum AppNotificationType {
  winningResult('winning_result', '당첨 결과'),
  postComment('post_comment', '댓글'),
  postLike('post_like', '좋아요'),
  notice('notice', '공지');

  const AppNotificationType(this.value, this.label);

  final String value;
  final String label;

  static AppNotificationType fromValue(String? value) {
    for (final type in AppNotificationType.values) {
      if (type.value == value) {
        return type;
      }
    }

    return AppNotificationType.notice;
  }
}

class AppNotificationTargetType {
  const AppNotificationTargetType._();

  static const savedNumber = 'savedNumber';
  static const communityPost = 'communityPost';
  static const communityComment = 'communityComment';
  static const notice = 'notice';
}

class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.createdAt,
    this.targetType,
    this.targetId,
    this.round,
    this.isRead = false,
    this.readAt,
  });

  factory AppNotification.fromMap(String id, Map<String, dynamic> map) {
    return AppNotification(
      id: id,
      type: AppNotificationType.fromValue(map['type'] as String?),
      title: map['title'] as String? ?? '',
      message: map['message'] as String? ?? '',
      targetType: map['targetType'] as String?,
      targetId: map['targetId'] as String?,
      round: map['round'] as int?,
      isRead: map['isRead'] as bool? ?? false,
      createdAt: _dateTimeFromMapValue(map['createdAt']) ?? DateTime.now(),
      readAt: _dateTimeFromMapValue(map['readAt']),
    );
  }

  final String id;
  final AppNotificationType type;
  final String title;
  final String message;
  final String? targetType;
  final String? targetId;
  final int? round;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;

  AppNotification copyWith({
    AppNotificationType? type,
    String? title,
    String? message,
    String? targetType,
    String? targetId,
    int? round,
    bool? isRead,
    DateTime? createdAt,
    DateTime? readAt,
  }) {
    return AppNotification(
      id: id,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      targetType: targetType ?? this.targetType,
      targetId: targetId ?? this.targetId,
      round: round ?? this.round,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type.value,
      'title': title,
      'message': message,
      'targetType': targetType,
      'targetId': targetId,
      'round': round,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
      'readAt': readAt == null ? null : Timestamp.fromDate(readAt!),
    };
  }

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
