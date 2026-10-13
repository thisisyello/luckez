import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:luckez/constants/lotto_round.dart';
import 'package:luckez/controllers/winning_rounds_controller.dart';
import 'package:luckez/models/lotto_winning_round.dart';
import 'package:luckez/repositories/winning_round_repository.dart';

class _TestRepository implements WinningRoundRepository {
  final stream = StreamController<List<LottoWinningRound>>();
  int watchCount = 0;
  LottoWinningRound? saved;

  @override
  Stream<List<LottoWinningRound>> watchWinningRounds() {
    watchCount++;
    return stream.stream;
  }

  @override
  Future<List<LottoWinningRound>> fetchWinningRounds() async => [];

  @override
  Future<void> saveWinningRound(LottoWinningRound round) async {
    saved = round;
  }
}

void main() {
  late _TestRepository repository;
  late WinningRoundsController controller;
  const first = LottoWinningRound(
    round: 100,
    numbers: [1, 2, 3, 4, 5, 6],
    bonusNumber: 7,
  );
  const next = LottoWinningRound(
    round: 101,
    numbers: [8, 9, 10, 11, 12, 13],
    bonusNumber: 14,
  );

  setUp(() {
    repository = _TestRepository();
    controller = WinningRoundsController(repository: repository);
  });
  tearDown(() async {
    controller.dispose();
    await repository.stream.close();
  });

  Future<void> emit(List<LottoWinningRound> rounds) async {
    repository.stream.add(rounds);
    await Future<void>.delayed(Duration.zero);
  }

  test('Starts loading and subscribes only once', () {
    expect(controller.isLoading, isTrue);
    expect(controller.hasError, isFalse);
    expect(controller.rounds, isEmpty);
    expect(controller.roundInfo.activeRound, initialActiveRound);
    expect(controller.roundInfo.latestDrawRound, initialLatestDrawRound);
    controller.start();
    controller.start();
    expect(repository.watchCount, 1);
  });

  test('Updates rounds, active round and listeners from the stream', () async {
    var notifications = 0;
    controller.addListener(() => notifications++);
    controller.start();
    await emit([first]);
    expect(controller.isLoading, isFalse);
    expect(controller.roundInfo.latestDrawRound, 100);
    expect(controller.roundInfo.activeRound, 101);
    await emit([first, next]);
    expect(controller.rounds, [first, next]);
    expect(controller.roundInfo.latestDrawRound, 101);
    expect(controller.roundInfo.activeRound, 102);
    expect(notifications, 2);
  });

  test('Empty data completes loading without error', () async {
    controller.start();
    await emit([]);
    expect(controller.isLoading, isFalse);
    expect(controller.hasError, isFalse);
    expect(controller.rounds, isEmpty);
  });

  test('Error clears rounds and later data restores state', () async {
    controller.start();
    await emit([first]);
    repository.stream.addError(StateError('Read failed'));
    await Future<void>.delayed(Duration.zero);
    expect(controller.hasError, isTrue);
    expect(controller.isLoading, isFalse);
    expect(controller.rounds, isEmpty);
    await emit([first, next]);
    expect(controller.hasError, isFalse);
    expect(controller.roundInfo.activeRound, 102);
  });

  test('Looks up exact rounds and prevents replacing the exposed list',
      () async {
    controller.start();
    final input = [first];
    await emit(input);
    input.clear();
    expect(controller.findRound(100), first);
    expect(controller.findRound(99), isNull);
    expect(controller.findRound(null), isNull);
    expect(() => controller.rounds.clear(), throwsUnsupportedError);
  });

  test('Saves through repository without inventing stream updates', () async {
    controller.start();
    await controller.saveWinningRound(next);
    expect(repository.saved, next);
    expect(controller.rounds, isEmpty);
  });

  test('Dispose cancels the subscription and prevents notifications', () async {
    final other = WinningRoundsController(repository: repository);
    var notifications = 0;
    other.addListener(() => notifications++);
    other.start();
    expect(repository.stream.hasListener, isTrue);
    other.dispose();
    await emit([first]);
    expect(repository.stream.hasListener, isFalse);
    expect(notifications, 0);
  });
}
