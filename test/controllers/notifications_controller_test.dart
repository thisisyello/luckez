import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:luckez/controllers/notifications_controller.dart';
import 'package:luckez/repositories/notification_repository.dart';

void main() {
  late _TestRepository repository;
  late NotificationsController controller;

  Future<void> flush() => Future<void>.delayed(Duration.zero);

  setUp(() {
    repository = _TestRepository();
    controller = NotificationsController(repository: repository);
  });
  tearDown(() async {
    controller.dispose();
    for (final stream in repository.streams.values) {
      await stream.close();
    }
  });

  test('signed out state does not subscribe', () {
    controller.bindUser(null);
    expect(controller.unreadCount, 0);
    expect(controller.hasUnread, isFalse);
    expect(controller.hasError, isFalse);
    expect(repository.watched, isEmpty);
  });

  test('same account binds only once and stream updates unread state',
      () async {
    var notifications = 0;
    controller.addListener(() => notifications++);
    controller.bindUser('a');
    controller.bindUser('a');
    repository.stream('a').add(3);
    await flush();
    expect(repository.watched, ['a']);
    expect(controller.unreadCount, 3);
    expect(controller.hasUnread, isTrue);
    expect(notifications, 2);
    repository.stream('a').add(0);
    await flush();
    expect(controller.hasUnread, isFalse);
  });

  test('account switch clears badge and cancels previous subscription',
      () async {
    controller.bindUser('a');
    repository.stream('a').add(8);
    await flush();
    controller.bindUser('b');
    expect(controller.unreadCount, 0);
    expect(repository.stream('a').hasListener, isFalse);
    repository.stream('a').add(99);
    repository.stream('b').add(2);
    await flush();
    expect(controller.unreadCount, 2);
    expect(repository.watched, ['a', 'b']);
  });

  test('logout clears count and ignores previous account events', () async {
    controller.bindUser('a');
    repository.stream('a').add(4);
    await flush();
    controller.bindUser(null);
    repository.stream('a').add(7);
    await flush();
    expect(controller.unreadCount, 0);
    expect(controller.hasUnread, isFalse);
    expect(repository.stream('a').hasListener, isFalse);
  });

  test('stream error hides badge and later snapshot recovers', () async {
    controller.bindUser('a');
    repository.stream('a').add(4);
    await flush();
    repository.stream('a').addError(StateError('read failed'));
    await flush();
    expect(controller.unreadCount, 0);
    expect(controller.hasError, isTrue);
    repository.stream('a').add(1);
    await flush();
    expect(controller.unreadCount, 1);
    expect(controller.hasError, isFalse);
  });

  test('account switch resets previous subscription error', () async {
    controller.bindUser('a');
    repository.stream('a').addError(StateError('read failed'));
    await flush();
    controller.bindUser('b');
    expect(controller.hasError, isFalse);
    expect(controller.unreadCount, 0);
  });

  test('returning to same account establishes a new subscription', () async {
    controller.bindUser('a');
    controller.bindUser('b');
    controller.bindUser('a');
    repository.stream('a').add(5);
    await flush();
    expect(repository.watched, ['a', 'b', 'a']);
    expect(controller.unreadCount, 5);
  });

  test('dispose cancels subscription and prevents later notifications',
      () async {
    final other = NotificationsController(repository: repository);
    var notifications = 0;
    other.addListener(() => notifications++);
    other.bindUser('a');
    other.dispose();
    other.bindUser('b');
    repository.stream('a').add(5);
    await flush();
    expect(repository.stream('a').hasListener, isFalse);
    expect(repository.watched, ['a']);
    expect(notifications, 1);
    expect(other.unreadCount, 0);
  });
}

class _TestRepository implements NotificationRepository {
  final streams = <String, StreamController<int>>{};
  final watched = <String>[];

  StreamController<int> stream(String uid) =>
      streams.putIfAbsent(uid, () => StreamController<int>.broadcast());

  @override
  Stream<int> watchUnreadCount(String userId) {
    watched.add(userId);
    return stream(userId).stream;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
