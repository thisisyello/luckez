import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:luckez/controllers/saved_numbers_controller.dart';
import 'package:luckez/models/lotto_result_status.dart';
import 'package:luckez/models/lotto_winning_round.dart';
import 'package:luckez/models/saved_lotto_number.dart';
import 'package:luckez/repositories/saved_lotto_number_repository.dart';

void main() {
  late _TestRepository repository;
  late SavedNumbersController controller;
  const winning = LottoWinningRound(
    round: 100,
    numbers: [1, 2, 3, 4, 5, 6],
    bonusNumber: 7,
  );

  SavedLottoNumber number(
    String id, {
    int round = 100,
    List<int> numbers = const [1, 2, 3, 4, 5, 6],
    bool purchased = false,
  }) =>
      SavedLottoNumber(
        id: id,
        numbers: numbers,
        round: round,
        createdAt: DateTime(2026, 1, 1),
        isPurchased: purchased,
      );

  Future<void> flush() => Future<void>.delayed(Duration.zero);
  Future<void> emit(List<SavedLottoNumber> numbers, {String uid = 'a'}) async {
    repository.stream(uid).add(numbers);
    await flush();
  }

  setUp(() {
    repository = _TestRepository();
    controller = SavedNumbersController(repository: repository);
  });
  tearDown(() async {
    controller.dispose();
    for (final stream in repository.streams.values) {
      await stream.close();
    }
  });

  test('binds once, exposes immutable snapshots and counts purchased numbers',
      () async {
    controller.bindUser('a');
    controller.bindUser('a');
    final input = [number('1'), number('2', purchased: true)];
    await emit(input);
    input.clear();
    expect(repository.watched, ['a']);
    expect(controller.numbers.length, 2);
    expect(controller.purchasedCount, 1);
    expect(() => controller.numbers.clear(), throwsUnsupportedError);
  });

  test('account switch and logout clear list and cancel previous subscription',
      () async {
    controller.bindUser('a');
    await emit([number('old')]);
    controller.bindUser('b');
    expect(controller.numbers, isEmpty);
    expect(repository.stream('a').hasListener, isFalse);
    await emit([number('late')]);
    await emit([number('new')], uid: 'b');
    expect(controller.numbers.single.id, 'new');
    controller.bindUser(null);
    expect(controller.numbers, isEmpty);
    expect(repository.stream('b').hasListener, isFalse);
  });

  test('stream errors are reported and later snapshots recover', () async {
    controller.bindUser('a');
    repository.stream('a').addError(StateError('read failed'));
    await flush();
    expect(controller.hasError, isTrue);
    expect(controller.errorRevision, 1);
    await emit([number('1')]);
    expect(controller.hasError, isFalse);
    expect(controller.numbers.length, 1);
  });

  test('save copies input, keeps active round and waits for stream updates',
      () async {
    controller.bindUser('a');
    final input = [1, 2, 3, 4, 5, 6];
    expect(await controller.save(input, round: 101), isTrue);
    input.clear();
    final saved = repository.saved.single.number;
    expect(repository.saved.single.uid, 'a');
    expect(saved.numbers, [1, 2, 3, 4, 5, 6]);
    expect(saved.round, 101);
    expect(saved.resultStatus, LottoResultStatus.pending);
    expect(saved.id, saved.createdAt.microsecondsSinceEpoch.toString());
    expect(controller.numbers, isEmpty);
  });

  test('save applies results only when winning round matches', () async {
    controller.bindUser('a');
    await controller
        .save([1, 2, 3, 4, 5, 6], round: 100, winningRound: winning);
    await controller
        .save([1, 2, 3, 4, 5, 6], round: 101, winningRound: winning);
    expect(repository.saved.first.number.resultStatus, LottoResultStatus.first);
    expect(repository.saved.first.number.matchCount, 6);
    expect(repository.saved.first.number.checkedAt, isNotNull);
    expect(
        repository.saved.last.number.resultStatus, LottoResultStatus.pending);
    expect(repository.saved.last.number.checkedAt, isNull);
  });

  test('purchase toggle preserves number data until stream confirms change',
      () async {
    controller.bindUser('a');
    await emit([number('1')]);
    expect(await controller.togglePurchased('1'), isTrue);
    final updated = repository.updated.single.number;
    expect(updated.isPurchased, isTrue);
    expect(updated.updatedAt, isNotNull);
    expect(updated.numbers, controller.numbers.single.numbers);
    expect(controller.purchasedCount, 0);
    await emit([updated]);
    expect(controller.purchasedCount, 1);
    await controller.togglePurchased('1');
    expect(repository.updated.last.number.isPurchased, isFalse);
  });

  test('editing sorts copied input and recalculates matching round', () async {
    controller.bindUser('a');
    await emit([number('1', purchased: true)]);
    final input = [9, 4, 3, 2, 1, 7];
    expect(await controller.updateNumbers('1', input, winningRound: winning),
        isTrue);
    final updated = repository.updated.single.number;
    expect(input, [9, 4, 3, 2, 1, 7]);
    expect(updated.numbers, [1, 2, 3, 4, 7, 9]);
    expect(updated.resultStatus, LottoResultStatus.fourth);
    expect(updated.matchCount, 4);
    expect(updated.isBonusMatched, isTrue);
    expect(updated.checkedAt, isNotNull);
    expect(updated.isPurchased, isTrue);
    expect(updated.createdAt, controller.numbers.single.createdAt);
  });

  test('missing numbers do not trigger updates', () async {
    controller.bindUser('a');
    expect(await controller.togglePurchased('missing'), isFalse);
    expect(
        await controller.updateNumbers('missing', [1, 2, 3, 4, 5, 6]), isFalse);
    expect(controller.roundFor('missing'), isNull);
    expect(repository.updated, isEmpty);
  });

  test('delete uses bound user and leaves list to the stream', () async {
    controller.bindUser('a');
    await emit([number('1')]);
    expect(await controller.delete('1'), isTrue);
    expect(repository.deleted, [('a', '1')]);
    expect(controller.numbers.length, 1);
    await emit([]);
    expect(controller.numbers, isEmpty);
  });

  test('write failures propagate without local optimistic changes', () async {
    controller.bindUser('a');
    await emit([number('1')]);
    repository.failWrites = true;
    await expectLater(
        controller.save([1, 2, 3, 4, 5, 6], round: 101), throwsStateError);
    await expectLater(controller.togglePurchased('1'), throwsStateError);
    await expectLater(
        controller.updateNumbers('1', [1, 2, 3, 4, 5, 6]), throwsStateError);
    await expectLater(controller.delete('1'), throwsStateError);
    expect(controller.numbers.single.isPurchased, isFalse);
  });

  test('signed out operations are rejected', () async {
    await expectLater(
        controller.save([1, 2, 3, 4, 5, 6], round: 101), throwsStateError);
    await expectLater(controller.togglePurchased('1'), throwsStateError);
    await expectLater(controller.updateNumbers('1', []), throwsStateError);
    await expectLater(controller.delete('1'), throwsStateError);
    await expectLater(controller.refreshResults(winning), throwsStateError);
    expect(repository.saved, isEmpty);
    expect(repository.updated, isEmpty);
  });

  test('refresh updates only matching round and returns best result summary',
      () async {
    controller.bindUser('a');
    await emit([
      number('fifth', numbers: [1, 2, 3, 40, 41, 42]),
      number('first'),
      number('other', round: 101),
    ]);
    final summary = await controller.refreshResults(winning);
    expect(summary?.savedNumbersCount, 2);
    expect(summary?.bestResultStatus, LottoResultStatus.first);
    expect(
        repository.updated.map((write) => write.number.id), ['fifth', 'first']);
    expect(repository.updated.first.number.checkedAt,
        repository.updated.last.number.checkedAt);
    expect(repository.updated.first.number.updatedAt, isNotNull);
  });

  test('refresh returns no summary when no saved round matches', () async {
    controller.bindUser('a');
    await emit([number('other', round: 101)]);
    expect(await controller.refreshResults(winning), isNull);
    expect(repository.updated, isEmpty);
  });

  test('account switch during refresh stops remaining writes and summary',
      () async {
    controller.bindUser('a');
    await emit([number('1'), number('2')]);
    final pending = Completer<void>();
    repository.pendingWrite = pending.future;
    final result = controller.refreshResults(winning);
    await flush();
    controller.bindUser('b');
    pending.complete();
    expect(await result, isNull);
    expect(repository.updated.length, 1);
    expect(repository.updated.single.uid, 'a');
    expect(controller.numbers, isEmpty);
  });

  test('account switch during save suppresses success for new session',
      () async {
    controller.bindUser('a');
    final pending = Completer<void>();
    repository.pendingWrite = pending.future;
    final result = controller.save([1, 2, 3, 4, 5, 6], round: 101);
    controller.bindUser('b');
    pending.complete();
    expect(await result, isFalse);
    expect(repository.saved.single.uid, 'a');
  });

  test('dispose cancels subscription and ignores later events', () async {
    final other = SavedNumbersController(repository: repository);
    var notifications = 0;
    other.addListener(() => notifications++);
    other.bindUser('a');
    expect(notifications, 1);
    other.dispose();
    await emit([number('late')]);
    expect(repository.stream('a').hasListener, isFalse);
    expect(notifications, 1);
    expect(other.numbers, isEmpty);
  });
}

class _TestRepository implements SavedLottoNumberRepository {
  final streams = <String, StreamController<List<SavedLottoNumber>>>{};
  final watched = <String>[];
  final saved = <({String uid, SavedLottoNumber number})>[];
  final updated = <({String uid, SavedLottoNumber number})>[];
  final deleted = <(String, String)>[];
  bool failWrites = false;
  Future<void>? pendingWrite;

  StreamController<List<SavedLottoNumber>> stream(String uid) =>
      streams.putIfAbsent(
          uid, () => StreamController<List<SavedLottoNumber>>.broadcast());

  @override
  Stream<List<SavedLottoNumber>> watchSavedNumbers(String userId) {
    watched.add(userId);
    return stream(userId).stream;
  }

  Future<void> _write() async {
    if (failWrites) throw StateError('write failed');
    await pendingWrite;
  }

  @override
  Future<void> save(String userId, SavedLottoNumber number) async {
    saved.add((uid: userId, number: number));
    await _write();
  }

  @override
  Future<void> update(String userId, SavedLottoNumber number) async {
    updated.add((uid: userId, number: number));
    await _write();
  }

  @override
  Future<void> delete(String userId, String id) async {
    deleted.add((userId, id));
    await _write();
  }
}
