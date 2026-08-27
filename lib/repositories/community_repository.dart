import 'package:cloud_firestore/cloud_firestore.dart';
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

  CollectionReference<Map<String, dynamic>> _postsCollection() {
    return _firestore.collection('communityPosts');
  }
}
