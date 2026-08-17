import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:luckez/models/lotto_result_status.dart';

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

  factory SavedLottoNumber.fromMap(String id, Map<String, dynamic> map) {
    return SavedLottoNumber(
      id: id,
      numbers: List<int>.from(map['numbers'] as List<dynamic>),
      createdAt: _dateTimeFromMapValue(map['createdAt']) ?? DateTime.now(),
      updatedAt: _dateTimeFromMapValue(map['updatedAt']),
      round: map['round'] as int?,
      isPurchased: map['isPurchased'] as bool? ?? false,
      resultStatus: _resultStatusFromName(map['resultStatus'] as String?),
      matchCount: map['matchCount'] as int?,
      isBonusMatched: map['isBonusMatched'] as bool?,
      checkedAt: _dateTimeFromMapValue(map['checkedAt']),
    );
  }

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

  Map<String, dynamic> toMap() {
    return {
      'numbers': numbers,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt == null ? null : Timestamp.fromDate(updatedAt!),
      'round': round,
      'isPurchased': isPurchased,
      'resultStatus': resultStatus.name,
      'matchCount': matchCount,
      'isBonusMatched': isBonusMatched,
      'checkedAt': checkedAt == null ? null : Timestamp.fromDate(checkedAt!),
    };
  }

  static DateTime? _dateTimeFromMapValue(Object? value) {
    if (value == null) {
      return null;
    }

    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    return null;
  }

  static LottoResultStatus _resultStatusFromName(String? name) {
    for (final status in LottoResultStatus.values) {
      if (status.name == name) {
        return status;
      }
    }

    return LottoResultStatus.pending;
  }
}
