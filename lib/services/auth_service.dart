import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  AuthService({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  Future<void>? _googleSignInInitializeFuture;

  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) {
    return _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
  }) {
    return _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> signInWithGoogle() async {
    final googleProvider = GoogleAuthProvider();

    if (kIsWeb) {
      return _firebaseAuth.signInWithPopup(googleProvider);
    }

    await _ensureGoogleSignInInitialized();

    final GoogleSignInAccount googleUser;

    try {
      googleUser = await _googleSignIn.authenticate();
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled) {
        throw const AuthCancelledException();
      }

      rethrow;
    }

    final googleAuth = googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    return _firebaseAuth.signInWithCredential(credential);
  }

  Future<void> updateDisplayName(String displayName) async {
    final user = currentUser;

    if (user == null) {
      throw StateError('User is not signed in.');
    }

    await user.updateDisplayName(displayName);
    await user.reload();
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();

    if (!kIsWeb) {
      await _ensureGoogleSignInInitialized();
      await _googleSignIn.signOut();
    }
  }

  Future<void> _ensureGoogleSignInInitialized() {
    return _googleSignInInitializeFuture ??= _googleSignIn.initialize();
  }
}

class AuthCancelledException implements Exception {
  const AuthCancelledException();
}
