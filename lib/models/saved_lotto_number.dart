import 'package:randomlottonumber/models/lotto_result_status.dart';

class SavedLottoNumber {
  const SavedLottoNumber({
    required this.id,
    required this.numbers,
    required this.createdAt,
    this.updatedAt,
    this.round,
    this.isPurchased = false,
    this.resultStatus = LottoResultStatus.pending,
    this.matchCount,
    this.isBonusMatched,
    this.checkedAt,
  });

  final String id;
  final List<int> numbers;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int? round;
  final bool isPurchased;
  final LottoResultStatus resultStatus;
  final int? matchCount;
  final bool? isBonusMatched;
  final DateTime? checkedAt;

  SavedLottoNumber copyWith({
    String? id,
    List<int>? numbers,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? round,
    bool? isPurchased,
    LottoResultStatus? resultStatus,
    int? matchCount,
    bool? isBonusMatched,
    DateTime? checkedAt,
  }) {
    return SavedLottoNumber(
      id: id ?? this.id,
      numbers: numbers ?? this.numbers,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      round: round ?? this.round,
      isPurchased: isPurchased ?? this.isPurchased,
      resultStatus: resultStatus ?? this.resultStatus,
      matchCount: matchCount ?? this.matchCount,
      isBonusMatched: isBonusMatched ?? this.isBonusMatched,
      checkedAt: checkedAt ?? this.checkedAt,
    );
  }
}
