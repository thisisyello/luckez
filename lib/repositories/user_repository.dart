import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:luckez/models/user_profile.dart';

class UserRepository {
  UserRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<UserProfile> watchUserProfile(String userId) {
    return _usersCollection().doc(userId).snapshots().map((snapshot) {
      return UserProfile.fromMap(userId, snapshot.data());
    });
  }

  Future<void> ensureUserProfile(User user) async {
    final userRef = _usersCollection().doc(user.uid);
    final snapshot = await userRef.get();
    final now = FieldValue.serverTimestamp();

    if (!snapshot.exists) {
      await userRef.set({
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName,
        'photoUrl': user.photoURL,
        'role': 'user',
        'createdAt': now,
        'updatedAt': now,
      });
      return;
    }

    final data = snapshot.data() ?? <String, dynamic>{};
    final updateData = <String, dynamic>{
      'uid': user.uid,
      'email': user.email,
      'displayName': user.displayName,
      'updatedAt': now,
    };

    final authPhotoUrl = user.photoURL?.trim();
    final storedPhotoUrl = data['photoUrl'] as String?;

    if (authPhotoUrl != null &&
        authPhotoUrl.isNotEmpty &&
        (storedPhotoUrl == null || storedPhotoUrl.trim().isEmpty)) {
      updateData['photoUrl'] = authPhotoUrl;
    }

    if (!data.containsKey('role')) {
      updateData['role'] = 'user';
    }

    await userRef.set(updateData, SetOptions(merge: true));
  }

  Future<void> updateDisplayName({
    required String userId,
    required String displayName,
  }) {
    return _usersCollection().doc(userId).set({
      'displayName': displayName,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> updatePhotoUrl({
    required String userId,
    required String? photoUrl,
  }) {
    return _usersCollection().doc(userId).set({
      'photoUrl': photoUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  CollectionReference<Map<String, dynamic>> _usersCollection() {
    return _firestore.collection('users');
  }
}
