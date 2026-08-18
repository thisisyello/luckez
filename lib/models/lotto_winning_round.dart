import 'package:cloud_firestore/cloud_firestore.dart';

class LottoWinningRound {
  const LottoWinningRound({
    required this.round,
    required this.numbers,
    required this.bonusNumber,
    this.drawDate,
  });

  factory LottoWinningRound.fromMap(String id, Map<String, dynamic> map) {
    return LottoWinningRound(
      round: int.tryParse(id) ?? map['round'] as int,
      numbers: List<int>.from(map['numbers'] as List<dynamic>),
      bonusNumber: map['bonusNumber'] as int,
      drawDate: _dateTimeFromMapValue(map['drawDate']),
    );
  }

  final int round;
  final List<int> numbers;
  final int bonusNumber;
  final DateTime? drawDate;

  Map<String, dynamic> toMap() {
    return {
      'round': round,
      'numbers': numbers,
      'bonusNumber': bonusNumber,
      'drawDate': drawDate == null ? null : Timestamp.fromDate(drawDate!),
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
}
