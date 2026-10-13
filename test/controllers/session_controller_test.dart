import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luckez/controllers/session_controller.dart';
import 'package:luckez/models/user_profile.dart';
import 'package:luckez/repositories/user_repository.dart';
import 'package:luckez/services/auth_service.dart';

void main() {
  late _TestAuth auth;
  late _TestUsers users;
  late SessionController controller;
  var disposed = false;

  Future<void> flush() => Future<void>.delayed(Duration.zero);

  setUp(() {
    disposed = false;
    auth = _TestAuth();
    users = _TestUsers();
    controller = SessionController(authService: auth, userRepository: users);
  });

  tearDown(() async {
    if (!disposed) controller.dispose();
    await auth.events.close();
    for (final stream in users.streams.values) {
      await stream.close();
    }
  });

  test('starts only one auth subscription and begins signed out', () {
    controller.start();
    controller.start();
    expect(auth.watchCount, 1);
    expect(controller.userId, isNull);
    expect(controller.isAdmin, isFalse);
    expect(controller.displayName, isNull);
  });

  test('profile updates name, photo and role; sign out clears all', () async {
    controller.start();
    auth.emit(_TestUser('a', displayName: 'Auth name'));
    await flush();
    expect(controller.displayName, 'Auth name');
    expect(users.ensured, ['a']);
    users.stream('a').add(const UserProfile(
          uid: 'a',
          role: 'admin',
          displayName: 'Profile name',
          photoUrl: 'photo',
        ));
    await flush();
    expect(controller.displayName, 'Profile name');
    expect(controller.photoUrl, 'photo');
    expect(controller.isAdmin, isTrue);
    auth.emit(null);
    await flush();
    expect(controller.user, isNull);
    expect(controller.profile, isNull);
    expect(controller.photoUrl, isNull);
    expect(controller.isAdmin, isFalse);
    expect(users.stream('a').hasListener, isFalse);
  });

  test('account switch clears previous profile and ignores old events',
      () async {
    controller.start();
    auth.emit(_TestUser('a'));
    await flush();
    users.stream('a').add(const UserProfile(uid: 'a', role: 'admin'));
    await flush();
    auth.emit(_TestUser('b', email: 'b@example.com'));
    await flush();
    expect(controller.profile, isNull);
    expect(controller.isAdmin, isFalse);
    expect(controller.displayName, 'b@example.com');
    users.stream('a').add(const UserProfile(uid: 'a', role: 'admin'));
    users.stream('b').add(const UserProfile(uid: 'b', role: 'user'));
    await flush();
    expect(controller.userId, 'b');
    expect(controller.profile?.uid, 'b');
    expect(controller.isAdmin, isFalse);
  });

  test('profile errors clear role and allow later recovery', () async {
    controller.start();
    auth.emit(_TestUser('a'));
    await flush();
    users.stream('a').add(const UserProfile(uid: 'a', role: 'admin'));
    await flush();
    users.stream('a').addError(StateError('permission denied'));
    await flush();
    expect(controller.isAdmin, isFalse);
    expect(controller.errorRevision, 1);
    expect(controller.errorMessage, isNotNull);
    users.stream('a').add(const UserProfile(uid: 'a', role: 'admin'));
    await flush();
    expect(controller.isAdmin, isTrue);
  });

  test('late profile synchronization errors after sign out are ignored',
      () async {
    final pending = Completer<void>();
    users.pendingEnsure = pending.future;
    controller.start();
    auth.emit(_TestUser('a'));
    await flush();
    auth.emit(null);
    await flush();
    pending.completeError(StateError('late failure'));
    await flush();
    expect(controller.errorRevision, 0);
    expect(controller.userId, isNull);
  });

  test('name update writes Auth and profile and refreshes local state',
      () async {
    controller.start();
    auth.emit(_TestUser('a', displayName: 'Before'));
    await flush();
    users.stream('a').add(const UserProfile(
          uid: 'a',
          role: 'user',
          displayName: 'Before',
        ));
    await flush();
    await controller.updateDisplayName('After');
    expect(auth.currentUser?.displayName, 'After');
    expect(users.nameWrites, ['a:After']);
    expect(controller.displayName, 'After');
  });

  test('name update is rejected when signed out', () async {
    await expectLater(controller.updateDisplayName('Name'), throwsStateError);
    expect(users.nameWrites, isEmpty);
  });

  test('disposed controller cancels streams and ignores pending errors',
      () async {
    final pending = Completer<void>();
    users.pendingEnsure = pending.future;
    controller.start();
    auth.emit(_TestUser('a'));
    await flush();
    controller.dispose();
    disposed = true;
    expect(auth.events.hasListener, isFalse);
    expect(users.stream('a').hasListener, isFalse);
    pending.completeError(StateError('late failure'));
    await flush();
  });
}

class _TestUser implements User {
  _TestUser(this.uid, {this.email, this.displayName, this.photoURL});

  @override
  final String uid;
  @override
  final String? email;
  @override
  final String? displayName;
  @override
  final String? photoURL;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _TestAuth implements AuthService {
  final events = StreamController<User?>.broadcast();
  int watchCount = 0;

  @override
  User? currentUser;

  @override
  Stream<User?> get authStateChanges {
    watchCount++;
    return events.stream;
  }

  void emit(User? user) {
    currentUser = user;
    events.add(user);
  }

  @override
  Future<void> updateDisplayName(String name) async {
    final user = currentUser!;
    currentUser = _TestUser(
      user.uid,
      email: user.email,
      displayName: name,
      photoURL: user.photoURL,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _TestUsers implements UserRepository {
  final streams = <String, StreamController<UserProfile>>{};
  final ensured = <String>[];
  final nameWrites = <String>[];
  Future<void>? pendingEnsure;

  StreamController<UserProfile> stream(String uid) => streams.putIfAbsent(
        uid,
        () => StreamController<UserProfile>.broadcast(),
      );

  @override
  Stream<UserProfile> watchUserProfile(String userId) => stream(userId).stream;

  @override
  Future<void> ensureUserProfile(User user) async {
    ensured.add(user.uid);
    await pendingEnsure;
  }

  @override
  Future<void> updateDisplayName({
    required String userId,
    required String displayName,
  }) async {
    nameWrites.add('$userId:$displayName');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
