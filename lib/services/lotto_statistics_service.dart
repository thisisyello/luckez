import 'package:luckez/models/lotto_number_frequency.dart';
import 'package:luckez/models/lotto_winning_round.dart';

class LottoStatisticsService {
  const LottoStatisticsService();

  List<LottoNumberFrequency> calculateNumberFrequencies({
    required List<LottoWinningRound> rounds,
    required bool includeBonusNumber,
  }) {
    final counts = <int, int>{
      for (var number = 1; number <= 45; number++) number: 0,
    };

    for (final round in rounds) {
      for (final number in round.numbers) {
        counts[number] = counts[number]! + 1;
      }

      if (includeBonusNumber) {
        counts[round.bonusNumber] = counts[round.bonusNumber]! + 1;
      }
    }

    final sortedEntries = counts.entries.toList()
      ..sort((a, b) {
        final countCompare = b.value.compareTo(a.value);
        if (countCompare != 0) {
          return countCompare;
        }

        return a.key.compareTo(b.key);
      });

    return [
      for (var index = 0; index < sortedEntries.length; index++)
        LottoNumberFrequency(
          number: sortedEntries[index].key,
          count: sortedEntries[index].value,
          rank: index + 1,
        ),
    ];
  }
}
