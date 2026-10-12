import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:luckez/models/user_profile.dart';
import 'package:luckez/repositories/user_repository.dart';
import 'package:luckez/services/auth_service.dart';

class SessionController extends ChangeNotifier {
  SessionController({AuthService? authService, UserRepository? userRepository})
      : _authService = authService ?? AuthService(),
        _userRepository = userRepository ?? UserRepository();

  final AuthService _authService;
  final UserRepository _userRepository;
  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<UserProfile>? _profileSubscription;
  User? _user;
  UserProfile? _profile;
  bool _isDisposed = false;
  int _generation = 0;
  int _errorRevision = 0;
  String? _errorMessage;

  User? get user => _user;
  UserProfile? get profile => _profile;
  String? get userId => _user?.uid;
  bool get isAdmin => _profile?.role == 'admin';
  String? get email => _profile?.email ?? _user?.email;
  int get errorRevision => _errorRevision;
  String? get errorMessage => _errorMessage;

  String? get displayName {
    if (_user == null) return null;
    return _nonBlank(_profile?.displayName) ??
        _nonBlank(_user?.displayName) ??
        _nonBlank(email) ??
        '익명';
  }

  String? get photoUrl => _nonBlank(_profile?.photoUrl) ?? _user?.photoURL;

  String? _nonBlank(String? value) {
    final text = value?.trim();
    return text == null || text.isEmpty ? null : text;
  }

  void start() {
    if (_isDisposed || _authSubscription != null) return;
    _authSubscription = _authService.authStateChanges.listen(
      _onAuthChanged,
      onError: (Object error) {
        if (!_isDisposed) _reportError('로그인 상태를 확인하지 못했어요');
      },
    );
  }

  void _onAuthChanged(User? user) {
    if (_isDisposed) return;
    final generation = ++_generation;
    _profileSubscription?.cancel();
    _profileSubscription = null;
    _user = user;
    _profile = null;
    _errorMessage = null;
    notifyListeners();
    if (user == null) return;

    _profileSubscription = _userRepository.watchUserProfile(user.uid).listen(
      (profile) {
        if (!_isCurrent(generation)) return;
        _profile = profile;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (Object error) {
        if (!_isCurrent(generation)) return;
        _profile = null;
        _reportError('회원 정보를 불러오지 못했어요');
      },
    );
    unawaited(_ensureProfile(user, generation));
  }

  bool _isCurrent(int generation) => !_isDisposed && generation == _generation;

  Future<void> _ensureProfile(User user, int generation) async {
    try {
      await _userRepository.ensureUserProfile(user);
    } catch (_) {
      if (_isCurrent(generation)) _reportError('회원 정보를 동기화하지 못했어요');
    }
  }

  void _reportError(String message) {
    _errorMessage = message;
    _errorRevision++;
    notifyListeners();
  }

  Future<void> signInWithGoogle() async {
    await _authService.signInWithGoogle();
  }

  Future<void> signInWithEmail(String email, String password) async {
    await _authService.signInWithEmail(email: email, password: password);
  }

  Future<void> signUpWithEmail(
      String name, String email, String password) async {
    final credential = await _authService.signUpWithEmail(
      displayName: name.trim(),
      email: email,
      password: password,
    );
    final user = credential.user ?? _authService.currentUser;
    if (user != null) await _userRepository.ensureUserProfile(user);
  }

  Future<void> signOut() => _authService.signOut();

  Future<void> updateDisplayName(String name) async {
    final uid = userId;
    if (uid == null) throw StateError('User is not signed in.');
    final generation = _generation;
    await _authService.updateDisplayName(name);
    if (!_isCurrent(generation)) return;
    await _userRepository.updateDisplayName(userId: uid, displayName: name);
    if (!_isCurrent(generation)) return;
    _user = _authService.currentUser;
    _profile = _profile?.copyWith(displayName: name);
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _authSubscription?.cancel();
    _profileSubscription?.cancel();
    super.dispose();
  }
}
