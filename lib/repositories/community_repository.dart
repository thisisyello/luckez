import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:luckez/models/community_comment.dart';
import 'package:luckez/models/community_post.dart';

class CommunityRepository {
  CommunityRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<void> createPost({
    required String title,
    required String content,
    required String authorId,
    required String authorName,
  }) {
    final now = FieldValue.serverTimestamp();

    return _postsCollection().add({
      'title': title,
      'content': content,
      'authorId': authorId,
      'authorName': authorName,
      'commentCount': 0,
      'createdAt': now,
      'updatedAt': now,
      'deletedAt': null,
    });
  }

  Future<void> deletePost(String postId) {
    return _postsCollection().doc(postId).update({
      'deletedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> createComment({
    required String postId,
    required String content,
    required String authorId,
    required String authorName,
  }) {
    final now = FieldValue.serverTimestamp();
    final postRef = _postsCollection().doc(postId);
    final commentRef = _commentsCollection(postId).doc();
    final batch = _firestore.batch();

    batch.set(commentRef, {
      'content': content,
      'authorId': authorId,
      'authorName': authorName,
      'createdAt': now,
      'updatedAt': now,
      'deletedAt': null,
    });
    batch.update(postRef, {
      'commentCount': FieldValue.increment(1),
      'updatedAt': now,
    });

    return batch.commit();
  }

  Future<void> deleteComment({
    required String postId,
    required String commentId,
  }) {
    final now = FieldValue.serverTimestamp();
    final postRef = _postsCollection().doc(postId);
    final commentRef = _commentsCollection(postId).doc(commentId);
    final batch = _firestore.batch();

    batch.update(commentRef, {
      'deletedAt': now,
      'updatedAt': now,
    });
    batch.update(postRef, {
      'commentCount': FieldValue.increment(-1),
      'updatedAt': now,
    });

    return batch.commit();
  }

  Future<void> createReport({
    required String targetType,
    required String targetId,
    required String postId,
    required String reporterId,
    required String reason,
    String? description,
  }) {
    final now = FieldValue.serverTimestamp();

    return _reportsCollection().add({
      'targetType': targetType,
      'targetId': targetId,
      'postId': postId,
      'reporterId': reporterId,
      'reason': reason,
      'description': description?.trim() ?? '',
      'status': 'pending',
      'createdAt': now,
      'resolvedAt': null,
    });
  }

  Stream<List<CommunityPost>> watchPosts() {
    return _postsCollection()
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => CommunityPost.fromMap(doc.id, doc.data()))
              .where((post) => !post.isDeleted)
              .toList(),
        );
  }

  Stream<List<CommunityComment>> watchComments(String postId) {
    return _commentsCollection(postId)
        .orderBy('createdAt')
        .limit(100)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => CommunityComment.fromMap(doc.id, doc.data()))
              .where((comment) => !comment.isDeleted)
              .toList(),
        );
  }

  CollectionReference<Map<String, dynamic>> _postsCollection() {
    return _firestore.collection('communityPosts');
  }

  CollectionReference<Map<String, dynamic>> _commentsCollection(String postId) {
    return _postsCollection().doc(postId).collection('comments');
  }

  CollectionReference<Map<String, dynamic>> _reportsCollection() {
    return _firestore.collection('communityReports');
  }
}
