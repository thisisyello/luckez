class LottoRoundInfo {
  const LottoRoundInfo({
    required this.activeRound,
    required this.latestDrawRound,
    this.drawDate,
    this.salesCloseAt,
  });

  final int activeRound;
  final int latestDrawRound;
  final DateTime? drawDate;
  final DateTime? salesCloseAt;

  LottoRoundInfo copyWith({
    int? activeRound,
    int? latestDrawRound,
    DateTime? drawDate,
    DateTime? salesCloseAt,
  }) {
    return LottoRoundInfo(
      activeRound: activeRound ?? this.activeRound,
      latestDrawRound: latestDrawRound ?? this.latestDrawRound,
      drawDate: drawDate ?? this.drawDate,
      salesCloseAt: salesCloseAt ?? this.salesCloseAt,
    );
  }
}
