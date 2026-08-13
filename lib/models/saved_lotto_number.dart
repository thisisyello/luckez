class SavedLottoNumber {
  const SavedLottoNumber({
    required this.id,
    required this.numbers,
    required this.createdAt,
    this.round,
    this.isPurchased = false,
  });

  final String id;
  final List<int> numbers;
  final DateTime createdAt;
  final int? round;
  final bool isPurchased;

  SavedLottoNumber copyWith({
    String? id,
    List<int>? numbers,
    DateTime? createdAt,
    int? round,
    bool? isPurchased,
  }) {
    return SavedLottoNumber(
      id: id ?? this.id,
      numbers: numbers ?? this.numbers,
      createdAt: createdAt ?? this.createdAt,
      round: round ?? this.round,
      isPurchased: isPurchased ?? this.isPurchased,
    );
  }
}
