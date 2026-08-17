import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  AuthService({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseAuth _firebaseAuth;

  User? get currentUser => _firebaseAuth.currentUser;

  Future<User> signInAnonymouslyIfNeeded() async {
    final currentUser = _firebaseAuth.currentUser;

    if (currentUser != null) {
      return currentUser;
    }

    final credential = await _firebaseAuth.signInAnonymously();
    return credential.user!;
  }
}
