import 'package:randomlottonumber/models/lotto_match_result.dart';
import 'package:randomlottonumber/models/lotto_result_status.dart';
import 'package:randomlottonumber/models/lotto_winning_round.dart';
import 'package:randomlottonumber/models/saved_lotto_number.dart';

class LottoResultChecker {
  const LottoResultChecker();

  LottoMatchResult check({
    required SavedLottoNumber savedNumber,
    required LottoWinningRound winningRound,
  }) {
    if (savedNumber.round == null || savedNumber.round != winningRound.round) {
      return const LottoMatchResult(
        status: LottoResultStatus.pending,
        matchCount: 0,
        isBonusMatched: false,
      );
    }

    final winningNumbers = winningRound.numbers.toSet();
    final matchCount = savedNumber.numbers
        .where((number) => winningNumbers.contains(number))
        .length;
    final isBonusMatched =
        savedNumber.numbers.contains(winningRound.bonusNumber);

    return LottoMatchResult(
      status: _getStatus(
        matchCount: matchCount,
        isBonusMatched: isBonusMatched,
      ),
      matchCount: matchCount,
      isBonusMatched: isBonusMatched,
    );
  }

  LottoResultStatus _getStatus({
    required int matchCount,
    required bool isBonusMatched,
  }) {
    if (matchCount == 6) {
      return LottoResultStatus.first;
    }

    if (matchCount == 5 && isBonusMatched) {
      return LottoResultStatus.second;
    }

    if (matchCount == 5) {
      return LottoResultStatus.third;
    }

    if (matchCount == 4) {
      return LottoResultStatus.fourth;
    }

    if (matchCount == 3) {
      return LottoResultStatus.fifth;
    }

    return LottoResultStatus.notWon;
  }
}
