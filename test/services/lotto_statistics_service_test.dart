import 'package:flutter_test/flutter_test.dart';
import 'package:luckez/models/lotto_winning_round.dart';
import 'package:luckez/services/lotto_statistics_service.dart';

void main() {
  const service = LottoStatisticsService();
  const rounds = [
    LottoWinningRound(round: 1, numbers: [1, 2, 3, 4, 5, 6], bonusNumber: 7),
    LottoWinningRound(round: 2, numbers: [1, 2, 8, 9, 10, 45], bonusNumber: 3),
  ];

  test('Excludes bonus and counts all 45 numbers', () {
    final result = service.calculateNumberFrequencies(
      rounds: rounds,
      includeBonusNumber: false,
    );
    final counts = {for (final entry in result) entry.number: entry.count};
    expect(result.length, 45);
    expect(counts.keys, containsAll(List.generate(45, (i) => i + 1)));
    expect(counts[1], 2);
    expect(counts[2], 2);
    expect(counts[3], 1);
    expect(counts[7], 0);
    expect(counts[45], 1);
    expect(counts[44], 0);
    expect(result.fold<int>(0, (total, entry) => total + entry.count), 12);
  });

  test('Includes bonus once per round and updates ranking', () {
    final result = service.calculateNumberFrequencies(
      rounds: rounds,
      includeBonusNumber: true,
    );
    final counts = {for (final entry in result) entry.number: entry.count};
    expect(counts[3], 2);
    expect(counts[7], 1);
    expect(counts[1], 2);
    expect(result.take(3).map((entry) => entry.number), [1, 2, 3]);
    expect(result.fold<int>(0, (total, entry) => total + entry.count), 14);
  });

  test('Sorts by count descending then number ascending with sequential ranks',
      () {
    final result = service.calculateNumberFrequencies(
      rounds: rounds,
      includeBonusNumber: false,
    );
    expect(result.take(11).map((entry) => entry.number),
        [1, 2, 3, 4, 5, 6, 8, 9, 10, 45, 7]);
    expect(result.map((entry) => entry.rank), List.generate(45, (i) => i + 1));
  });

  for (final includeBonus in [false, true]) {
    test('Empty rounds return zero counts (bonus: $includeBonus)', () {
      final result = service.calculateNumberFrequencies(
        rounds: [],
        includeBonusNumber: includeBonus,
      );
      expect(result.length, 45);
      expect(
          result.map((entry) => entry.number), List.generate(45, (i) => i + 1));
      expect(result.every((entry) => entry.count == 0), isTrue);
      expect(
          result.map((entry) => entry.rank), List.generate(45, (i) => i + 1));
    });
  }

  test('Round order does not change frequency results', () {
    final forward = service.calculateNumberFrequencies(
      rounds: rounds,
      includeBonusNumber: true,
    );
    final reverse = service.calculateNumberFrequencies(
      rounds: rounds.reversed.toList(),
      includeBonusNumber: true,
    );
    expect(reverse.map((entry) => (entry.number, entry.count, entry.rank)),
        forward.map((entry) => (entry.number, entry.count, entry.rank)));
  });
}
