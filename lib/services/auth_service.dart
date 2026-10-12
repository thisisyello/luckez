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

  Future<void> sendPasswordResetEmail(String email) {
    return _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future<void> reauthenticateWithPassword(String email, String password) async {
    final user = currentUser;
    if (user == null) {
      throw FirebaseAuthException(code: 'user-not-found');
    }
    if (user.email?.toLowerCase() != email.trim().toLowerCase()) {
      throw FirebaseAuthException(code: 'user-mismatch');
    }
    if (!user.providerData
        .any((provider) => provider.providerId == 'password')) {
      throw FirebaseAuthException(code: 'password-provider-required');
    }
    await user.reauthenticateWithCredential(
      EmailAuthProvider.credential(email: email.trim(), password: password),
    );
  }

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
    required String displayName,
    required String email,
    required String password,
  }) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await credential.user?.updateDisplayName(displayName);
    await credential.user?.reload();

    return credential;
  }

  Future<UserCredential> signInWithGoogle() async {
    final googleProvider = GoogleAuthProvider();

    if (kIsWeb) {
      return _firebaseAuth.signInWithPopup(googleProvider);
    }

    return _firebaseAuth.signInWithCredential(await _googleCredential());
  }

  Future<void> reauthenticateWithGoogle() async {
    final user = currentUser;
    if (user == null) {
      throw FirebaseAuthException(code: 'user-not-found');
    }
    if (!user.providerData
        .any((provider) => provider.providerId == 'google.com')) {
      throw FirebaseAuthException(code: 'google-provider-required');
    }
    try {
      if (kIsWeb) {
        await user.reauthenticateWithPopup(
          GoogleAuthProvider()
            ..setCustomParameters({'prompt': 'select_account'}),
        );
      } else {
        await user.reauthenticateWithCredential(await _googleCredential());
      }
    } on FirebaseAuthException catch (error) {
      if (error.code == 'popup-closed-by-user' ||
          error.code == 'cancelled-popup-request') {
        throw const AuthCancelledException();
      }
      rethrow;
    }
  }

  Future<OAuthCredential> _googleCredential() async {
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

    return credential;
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
