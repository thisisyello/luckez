import 'package:flutter_test/flutter_test.dart';
import 'package:luckez/models/lotto_result_status.dart';
import 'package:luckez/models/lotto_winning_round.dart';
import 'package:luckez/models/saved_lotto_number.dart';
import 'package:luckez/services/lotto_result_checker.dart';

void main() {
  const checker = LottoResultChecker();
  const winningRound = LottoWinningRound(
    round: 100,
    numbers: [1, 2, 3, 4, 5, 6],
    bonusNumber: 7,
  );

  SavedLottoNumber saved(List<int> numbers, {int? round = 100}) {
    return SavedLottoNumber(
      id: 'test-number',
      numbers: numbers,
      createdAt: DateTime(2026, 1, 1),
      round: round,
    );
  }

  final cases = [
    (
      label: 'six matches',
      numbers: [1, 2, 3, 4, 5, 6],
      status: LottoResultStatus.first,
      count: 6,
      bonus: false
    ),
    (
      label: 'five matches with bonus',
      numbers: [1, 2, 3, 4, 5, 7],
      status: LottoResultStatus.second,
      count: 5,
      bonus: true
    ),
    (
      label: 'five matches without bonus',
      numbers: [1, 2, 3, 4, 5, 8],
      status: LottoResultStatus.third,
      count: 5,
      bonus: false
    ),
    (
      label: 'four matches',
      numbers: [1, 2, 3, 4, 8, 9],
      status: LottoResultStatus.fourth,
      count: 4,
      bonus: false
    ),
    (
      label: 'three matches',
      numbers: [1, 2, 3, 8, 9, 10],
      status: LottoResultStatus.fifth,
      count: 3,
      bonus: false
    ),
    (
      label: 'two matches',
      numbers: [1, 2, 8, 9, 10, 11],
      status: LottoResultStatus.notWon,
      count: 2,
      bonus: false
    ),
    (
      label: 'one match',
      numbers: [1, 8, 9, 10, 11, 12],
      status: LottoResultStatus.notWon,
      count: 1,
      bonus: false
    ),
    (
      label: 'no matches',
      numbers: [8, 9, 10, 11, 12, 13],
      status: LottoResultStatus.notWon,
      count: 0,
      bonus: false
    ),
    (
      label: 'bonus only does not win',
      numbers: [7, 8, 9, 10, 11, 12],
      status: LottoResultStatus.notWon,
      count: 0,
      bonus: true
    ),
    (
      label: 'two matches plus bonus does not win',
      numbers: [1, 2, 7, 8, 9, 10],
      status: LottoResultStatus.notWon,
      count: 2,
      bonus: true
    ),
    (
      label: 'four matches plus bonus stays fourth',
      numbers: [1, 2, 3, 4, 7, 8],
      status: LottoResultStatus.fourth,
      count: 4,
      bonus: true
    ),
    (
      label: 'three matches plus bonus stays fifth',
      numbers: [1, 2, 3, 7, 8, 9],
      status: LottoResultStatus.fifth,
      count: 3,
      bonus: true
    ),
  ];

  group('Same round prize classification', () {
    for (final sample in cases) {
      test(sample.label, () {
        final result = checker.check(
          savedNumber: saved(sample.numbers),
          winningRound: winningRound,
        );
        expect(result.status, sample.status);
        expect(result.matchCount, sample.count);
        expect(result.isBonusMatched, sample.bonus);
      });
    }
  });

  for (final round in <int?>[99, 101, null]) {
    test('Round $round is pending even when all numbers match', () {
      final result = checker.check(
        savedNumber: saved([1, 2, 3, 4, 5, 6], round: round),
        winningRound: winningRound,
      );
      expect(result.status, LottoResultStatus.pending);
      expect(result.matchCount, 0);
      expect(result.isBonusMatched, isFalse);
    });
  }

  test('Unsorted numbers produce the same prize without changing input', () {
    final numbers = [7, 5, 3, 1, 4, 2];
    final result = checker.check(
      savedNumber: saved(numbers),
      winningRound: winningRound,
    );
    expect(result.status, LottoResultStatus.second);
    expect(result.matchCount, 5);
    expect(result.isBonusMatched, isTrue);
    expect(numbers, [7, 5, 3, 1, 4, 2]);
  });
}
