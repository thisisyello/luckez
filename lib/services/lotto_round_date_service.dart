class LottoRoundDateService {
  const LottoRoundDateService();

  static final DateTime _firstDrawDate = DateTime(2002, 12, 7);

  DateTime getDrawDate(int round) {
    return _firstDrawDate.add(Duration(days: 7 * (round - 1)));
  }

  String getDrawDateLabel({
    required int round,
    required int latestDrawRound,
  }) {
    final drawDate = getDrawDate(round);
    final statusLabel = round <= latestDrawRound ? '추첨' : '추첨 예정';

    return '${_formatDate(drawDate)} $statusLabel';
  }

  String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$year.$month.$day';
  }
}
