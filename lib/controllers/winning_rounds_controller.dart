import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:luckez/constants/lotto_round.dart';
import 'package:luckez/models/lotto_round_info.dart';
import 'package:luckez/models/lotto_winning_round.dart';
import 'package:luckez/repositories/winning_round_repository.dart';

class WinningRoundsController extends ChangeNotifier {
  WinningRoundsController({WinningRoundRepository? repository})
      : _repository = repository ?? WinningRoundRepository();

  final WinningRoundRepository _repository;
  StreamSubscription<List<LottoWinningRound>>? _subscription;
  bool _isDisposed = false;
  List<LottoWinningRound> _rounds = const [];
  bool _isLoading = true;
  bool _hasError = false;
  LottoRoundInfo _roundInfo = const LottoRoundInfo(
    activeRound: initialActiveRound,
    latestDrawRound: initialLatestDrawRound,
  );

  List<LottoWinningRound> get rounds => _rounds;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  LottoRoundInfo get roundInfo => _roundInfo;

  void start() {
    if (_isDisposed || _subscription != null) return;
    _subscription = _repository.watchWinningRounds().listen(
      (rounds) {
        if (_isDisposed) return;
        _rounds = List.unmodifiable(rounds);
        _isLoading = false;
        _hasError = false;
        if (rounds.isNotEmpty) {
          _roundInfo = _roundInfo.copyWith(
            activeRound: rounds.last.round + 1,
            latestDrawRound: rounds.last.round,
          );
        }
        notifyListeners();
      },
      onError: (Object error, StackTrace stackTrace) {
        if (_isDisposed) return;
        _rounds = const [];
        _isLoading = false;
        _hasError = true;
        notifyListeners();
      },
    );
  }

  LottoWinningRound? findRound(int? round) {
    for (final winningRound in _rounds) {
      if (winningRound.round == round) return winningRound;
    }
    return null;
  }

  Future<void> saveWinningRound(LottoWinningRound round) {
    return _repository.saveWinningRound(round);
  }

  @override
  void dispose() {
    _isDisposed = true;
    _subscription?.cancel();
    super.dispose();
  }
}
