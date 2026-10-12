import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:luckez/models/lotto_result_status.dart';
import 'package:luckez/models/lotto_winning_round.dart';
import 'package:luckez/models/saved_lotto_number.dart';
import 'package:luckez/repositories/saved_lotto_number_repository.dart';
import 'package:luckez/services/lotto_result_checker.dart';

class SavedNumbersController extends ChangeNotifier {
  SavedNumbersController({SavedLottoNumberRepository? repository})
      : _repository = repository ?? SavedLottoNumberRepository();

  final SavedLottoNumberRepository _repository;
  static const _resultChecker = LottoResultChecker();
  StreamSubscription<List<SavedLottoNumber>>? _subscription;
  List<SavedLottoNumber> _numbers = const [];
  String? _userId;
  bool _isDisposed = false;
  int _generation = 0;
  int _errorRevision = 0;
  bool _hasError = false;

  List<SavedLottoNumber> get numbers => _numbers;
  int get purchasedCount =>
      _numbers.where((number) => number.isPurchased).length;
  bool get hasError => _hasError;
  int get errorRevision => _errorRevision;

  void bindUser(String? userId) {
    if (_isDisposed || _userId == userId) return;
    final generation = ++_generation;
    _subscription?.cancel();
    _subscription = null;
    _userId = userId;
    _numbers = const [];
    _hasError = false;
    notifyListeners();
    if (userId == null) return;

    _subscription = _repository.watchSavedNumbers(userId).listen(
      (numbers) {
        if (!_isCurrent(generation)) return;
        _numbers = List.unmodifiable(numbers);
        _hasError = false;
        notifyListeners();
      },
      onError: (Object error) {
        if (!_isCurrent(generation)) return;
        _hasError = true;
        _errorRevision++;
        notifyListeners();
      },
    );
  }

  bool _isCurrent(int generation) => !_isDisposed && _generation == generation;

  String _requireUser() {
    if (_isDisposed || _userId == null) {
      throw StateError('User is not signed in.');
    }
    return _userId!;
  }

  SavedLottoNumber? _findNumber(String id) {
    for (final number in _numbers) {
      if (number.id == id) return number;
    }
    return null;
  }

  SavedLottoNumber _applyResult(
    SavedLottoNumber number,
    LottoWinningRound? winningRound,
    DateTime checkedAt,
  ) {
    if (winningRound == null || number.round != winningRound.round) {
      return number;
    }
    final result = _resultChecker.check(
      savedNumber: number,
      winningRound: winningRound,
    );
    return number.copyWith(
      resultStatus: result.status,
      matchCount: result.matchCount,
      isBonusMatched: result.isBonusMatched,
      checkedAt: checkedAt,
    );
  }

  Future<bool> save(
    List<int> numbers, {
    required int round,
    LottoWinningRound? winningRound,
  }) async {
    final userId = _requireUser();
    final generation = _generation;
    final now = DateTime.now();
    final number = _applyResult(
      SavedLottoNumber(
        id: now.microsecondsSinceEpoch.toString(),
        numbers: List<int>.from(numbers),
        createdAt: now,
        round: round,
      ),
      winningRound,
      now,
    );
    await _repository.save(userId, number);
    return _isCurrent(generation);
  }

  Future<bool> togglePurchased(String id) async {
    final userId = _requireUser();
    final generation = _generation;
    final number = _findNumber(id);
    if (number == null) return false;
    await _repository.update(
        userId,
        number.copyWith(
          isPurchased: !number.isPurchased,
          updatedAt: DateTime.now(),
        ));
    return _isCurrent(generation);
  }

  Future<bool> updateNumbers(
    String id,
    List<int> numbers, {
    LottoWinningRound? winningRound,
  }) async {
    final userId = _requireUser();
    final generation = _generation;
    final number = _findNumber(id);
    if (number == null) return false;
    final now = DateTime.now();
    final updated = _applyResult(
        number.copyWith(
          numbers: List<int>.from(numbers)..sort(),
          updatedAt: now,
        ),
        winningRound,
        now);
    await _repository.update(userId, updated);
    return _isCurrent(generation);
  }

  int? roundFor(String id) => _findNumber(id)?.round;

  Future<bool> delete(String id) async {
    final userId = _requireUser();
    final generation = _generation;
    await _repository.delete(userId, id);
    return _isCurrent(generation);
  }

  Future<({int savedNumbersCount, LottoResultStatus bestResultStatus})?>
      refreshResults(LottoWinningRound winningRound) async {
    final userId = _requireUser();
    final generation = _generation;
    final checkedAt = DateTime.now();
    final targets =
        _numbers.where((number) => number.round == winningRound.round).toList();
    if (targets.isEmpty) return null;
    var best = LottoResultStatus.notWon;

    // Snapshot the target list: repository writes can emit new stream values.
    for (final number in targets) {
      if (!_isCurrent(generation)) return null;
      final updated = _applyResult(number, winningRound, checkedAt)
          .copyWith(updatedAt: checkedAt);
      if (_resultRank(updated.resultStatus) > _resultRank(best)) {
        best = updated.resultStatus;
      }
      await _repository.update(userId, updated);
    }
    if (!_isCurrent(generation)) return null;
    return (savedNumbersCount: targets.length, bestResultStatus: best);
  }

  int _resultRank(LottoResultStatus status) => switch (status) {
        LottoResultStatus.pending || LottoResultStatus.notWon => 0,
        LottoResultStatus.fifth => 1,
        LottoResultStatus.fourth => 2,
        LottoResultStatus.third => 3,
        LottoResultStatus.second => 4,
        LottoResultStatus.first => 5,
      };

  @override
  void dispose() {
    _isDisposed = true;
    _subscription?.cancel();
    super.dispose();
  }
}
