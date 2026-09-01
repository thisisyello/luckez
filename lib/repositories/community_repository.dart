import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:luckez/models/community_comment.dart';
import 'package:luckez/models/community_liked_post.dart';
import 'package:luckez/models/community_my_comment.dart';
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
      'likeCount': 0,
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

  Future<void> updatePost({
    required String postId,
    required String title,
    required String content,
  }) {
    return _postsCollection().doc(postId).update({
      'title': title,
      'content': content,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> createComment({
    required String postId,
    required String content,
    required String authorId,
    required String authorName,
  }) async {
    final postRef = _postsCollection().doc(postId);
    final commentRef = _commentsCollection(postId).doc();
    final myCommentRef = _myCommentsCollection(authorId).doc(commentRef.id);

    await _firestore.runTransaction((transaction) async {
      final postSnapshot = await transaction.get(postRef);

      if (!postSnapshot.exists) {
        throw StateError('Post does not exist.');
      }

      final post = CommunityPost.fromMap(postSnapshot.id, postSnapshot.data()!);

      if (post.isDeleted) {
        throw StateError('Post has been deleted.');
      }

      final now = FieldValue.serverTimestamp();

      transaction.set(commentRef, {
        'content': content,
        'authorId': authorId,
        'authorName': authorName,
        'createdAt': now,
        'updatedAt': now,
        'deletedAt': null,
      });
      transaction.set(myCommentRef, {
        'commentId': commentRef.id,
        'postId': post.id,
        'postTitle': post.title,
        'content': content,
        'createdAt': now,
        'deletedAt': null,
      });
      transaction.update(postRef, {
        'commentCount': FieldValue.increment(1),
        'updatedAt': now,
      });
    });
  }

  Future<void> updateComment({
    required String postId,
    required String commentId,
    required String content,
    required String authorId,
  }) async {
    final commentRef = _commentsCollection(postId).doc(commentId);
    final myCommentRef = _myCommentsCollection(authorId).doc(commentId);

    await _firestore.runTransaction((transaction) async {
      final myCommentSnapshot = await transaction.get(myCommentRef);
      final now = FieldValue.serverTimestamp();

      transaction.update(commentRef, {
        'content': content,
        'updatedAt': now,
      });

      if (myCommentSnapshot.exists) {
        transaction.update(myCommentRef, {
          'content': content,
          'updatedAt': now,
        });
      }
    });
  }

  Future<void> deleteComment({
    required String postId,
    required String commentId,
  }) async {
    final postRef = _postsCollection().doc(postId);
    final commentRef = _commentsCollection(postId).doc(commentId);

    await _firestore.runTransaction((transaction) async {
      final commentSnapshot = await transaction.get(commentRef);

      if (!commentSnapshot.exists) {
        throw StateError('Comment does not exist.');
      }

      final comment = CommunityComment.fromMap(
        commentSnapshot.id,
        commentSnapshot.data()!,
      );
      final myCommentRef =
          _myCommentsCollection(comment.authorId).doc(commentId);
      final myCommentSnapshot = await transaction.get(myCommentRef);
      final now = FieldValue.serverTimestamp();

      transaction.update(commentRef, {
        'deletedAt': now,
        'updatedAt': now,
      });

      if (myCommentSnapshot.exists) {
        transaction.update(myCommentRef, {
          'deletedAt': now,
        });
      }

      transaction.update(postRef, {
        'commentCount': FieldValue.increment(-1),
        'updatedAt': now,
      });
    });
  }

  Future<void> togglePostLike({
    required String postId,
    required String userId,
  }) async {
    final postRef = _postsCollection().doc(postId);
    final likeRef = _likesCollection(postId).doc(userId);
    final likedPostRef = _likedPostsCollection(userId).doc(postId);

    await _firestore.runTransaction((transaction) async {
      final likeSnapshot = await transaction.get(likeRef);
      final postSnapshot = await transaction.get(postRef);

      if (!postSnapshot.exists) {
        throw StateError('Post does not exist.');
      }

      if (likeSnapshot.exists) {
        transaction.delete(likeRef);
        transaction.delete(likedPostRef);
        transaction.update(postRef, {
          'likeCount': FieldValue.increment(-1),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        return;
      }

      final post = CommunityPost.fromMap(postSnapshot.id, postSnapshot.data()!);
      final now = FieldValue.serverTimestamp();

      transaction.set(likeRef, {
        'userId': userId,
        'createdAt': now,
      });
      transaction.set(likedPostRef, {
        'postId': post.id,
        'title': post.title,
        'authorName': post.authorName,
        'likedAt': now,
        'postCreatedAt': postSnapshot.data()?['createdAt'],
      });
      transaction.update(postRef, {
        'likeCount': FieldValue.increment(1),
        'updatedAt': now,
      });
    });
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

  Stream<List<CommunityPost>> watchMyPosts(String userId) {
    return _postsCollection()
        .where('authorId', isEqualTo: userId)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      final posts = snapshot.docs
          .map((doc) => CommunityPost.fromMap(doc.id, doc.data()))
          .where((post) => !post.isDeleted)
          .toList();

      posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return posts;
    });
  }

  Future<CommunityPost?> fetchPost(String postId) async {
    final snapshot = await _postsCollection().doc(postId).get();

    if (!snapshot.exists) {
      return null;
    }

    final data = snapshot.data();

    if (data == null) {
      return null;
    }

    final post = CommunityPost.fromMap(snapshot.id, data);

    if (post.isDeleted) {
      return null;
    }

    return post;
  }

  Stream<List<CommunityLikedPost>> watchMyLikedPosts(String userId) {
    return _likedPostsCollection(userId)
        .orderBy('likedAt', descending: true)
        .limit(50)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => CommunityLikedPost.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Stream<List<CommunityMyComment>> watchMyComments(String userId) {
    return _myCommentsCollection(userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => CommunityMyComment.fromMap(doc.id, doc.data()))
              .where((comment) => !comment.isDeleted)
              .toList(),
        );
  }

  Stream<bool> watchPostLike({
    required String postId,
    required String? userId,
  }) {
    if (userId == null) {
      return Stream<bool>.value(false);
    }

    return _likesCollection(postId).doc(userId).snapshots().map(
          (snapshot) => snapshot.exists,
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

  CollectionReference<Map<String, dynamic>> _likesCollection(String postId) {
    return _postsCollection().doc(postId).collection('likes');
  }

  CollectionReference<Map<String, dynamic>> _reportsCollection() {
    return _firestore.collection('communityReports');
  }

  CollectionReference<Map<String, dynamic>> _likedPostsCollection(
    String userId,
  ) {
    return _firestore.collection('users').doc(userId).collection('likedPosts');
  }

  CollectionReference<Map<String, dynamic>> _myCommentsCollection(
    String userId,
  ) {
    return _firestore.collection('users').doc(userId).collection('myComments');
  }
}
