import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:luckez/models/app_notification.dart';

class NotificationRepository {
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

  CollectionReference<Map<String, dynamic>> _notificationsCollection(
    String userId,
  ) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications');
  }
}
