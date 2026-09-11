import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:luckez/models/app_notification.dart';

class NotificationRepository {
  static const _commentMessageMaxLength = 40;

  NotificationRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<List<AppNotification>> watchNotifications(
    String userId, {
    int limit = 50,
  }) {
    return _notificationsCollection(userId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => AppNotification.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Stream<int> watchUnreadCount(String userId) {
    return _notificationsCollection(userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.size);
  }

  Future<void> create({
    required String userId,
    required String notificationId,
    required AppNotificationType type,
    required String title,
    required String message,
    String? targetType,
    String? targetId,
    int? round,
  }) {
    return _notificationsCollection(userId).doc(notificationId).set({
      'type': type.value,
      'title': title,
      'message': message,
      'targetType': targetType,
      'targetId': targetId,
      'round': round,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
      'readAt': null,
    });
  }

  String postCommentNotificationId({
    required String postId,
    required String commentId,
  }) {
    return 'comment_${postId}_$commentId';
  }

  String postLikeNotificationId({
    required String postId,
    required String likerUserId,
  }) {
    return 'like_${postId}_$likerUserId';
  }

  DocumentReference<Map<String, dynamic>> notificationDocument({
    required String userId,
    required String notificationId,
  }) {
    return _notificationsCollection(userId).doc(notificationId);
  }

  void setPostCommentNotificationInTransaction({
    required Transaction transaction,
    required String postAuthorId,
    required String postId,
    required String commentId,
    required String commentAuthorId,
    required String commentAuthorName,
    required String commentContent,
  }) {
    if (postAuthorId == commentAuthorId) {
      return;
    }

    final notificationId = postCommentNotificationId(
      postId: postId,
      commentId: commentId,
    );

    transaction.set(
      notificationDocument(
        userId: postAuthorId,
        notificationId: notificationId,
      ),
      _communityNotificationData(
        type: AppNotificationType.postComment,
        title: '내 글에 댓글이 달렸어요',
        message: '$commentAuthorName: ${_shorten(commentContent)}',
        targetId: postId,
        actorId: commentAuthorId,
        actorName: commentAuthorName,
      ),
    );
  }

  void setPostLikeNotificationInTransaction({
    required Transaction transaction,
    required String postAuthorId,
    required String postId,
    required String likerUserId,
    required String likerName,
  }) {
    if (postAuthorId == likerUserId) {
      return;
    }

    final notificationId = postLikeNotificationId(
      postId: postId,
      likerUserId: likerUserId,
    );

    transaction.set(
      notificationDocument(
        userId: postAuthorId,
        notificationId: notificationId,
      ),
      _communityNotificationData(
        type: AppNotificationType.postLike,
        title: '내 글에 좋아요가 눌렸어요',
        message: '$likerName님이 내 글을 좋아해요',
        targetId: postId,
        actorId: likerUserId,
        actorName: likerName,
      ),
    );
  }

  Future<void> markAsRead({
    required String userId,
    required String notificationId,
  }) {
    return _notificationsCollection(userId).doc(notificationId).update({
      'isRead': true,
      'readAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> markAllAsRead(String userId) async {
    final snapshot = await _notificationsCollection(userId)
        .where('isRead', isEqualTo: false)
        .get();

    if (snapshot.docs.isEmpty) {
      return;
    }

    final batch = _firestore.batch();
    final now = FieldValue.serverTimestamp();

    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {
        'isRead': true,
        'readAt': now,
      });
    }

    await batch.commit();
  }

  Map<String, dynamic> _communityNotificationData({
    required AppNotificationType type,
    required String title,
    required String message,
    required String targetId,
    required String actorId,
    required String actorName,
  }) {
    return {
      'type': type.value,
      'title': title,
      'message': message,
      'targetType': AppNotificationTargetType.communityPost,
      'targetId': targetId,
      'round': null,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
      'readAt': null,
      'actorId': actorId,
      'actorName': actorName,
    };
  }

  String _shorten(String value) {
    final trimmed = value.trim();

    if (trimmed.length <= _commentMessageMaxLength) {
      return trimmed;
    }

    return '${trimmed.substring(0, _commentMessageMaxLength)}...';
  }

  CollectionReference<Map<String, dynamic>> _notificationsCollection(
    String userId,
  ) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications');
  }
}
