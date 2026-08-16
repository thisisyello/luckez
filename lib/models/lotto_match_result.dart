import 'package:randomlottonumber/models/lotto_result_status.dart';

class LottoMatchResult {
  const LottoMatchResult({
    required this.status,
    required this.matchCount,
    required this.isBonusMatched,
  });

  final LottoResultStatus status;
  final int matchCount;
  final bool isBonusMatched;
}
