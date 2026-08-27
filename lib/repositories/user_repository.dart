import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserRepository {
  UserRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

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
      'photoUrl': user.photoURL,
      'updatedAt': now,
    };

    if (!data.containsKey('role')) {
      updateData['role'] = 'user';
    }

    await userRef.set(updateData, SetOptions(merge: true));
  }

  CollectionReference<Map<String, dynamic>> _usersCollection() {
    return _firestore.collection('users');
  }
}
