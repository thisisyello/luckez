class LottoWinningRound {
  const LottoWinningRound({
    required this.round,
    required this.numbers,
    required this.bonusNumber,
    this.drawDate,
  });

  final int round;
  final List<int> numbers;
  final int bonusNumber;
  final DateTime? drawDate;
}
