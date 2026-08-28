enum CommunityReportReason {
  spam('spam', '스팸/홍보'),
  abuse('abuse', '욕설/비방'),
  inappropriate('inappropriate', '부적절한 내용'),
  etc('etc', '기타');

  const CommunityReportReason(this.value, this.label);

  final String value;
  final String label;
}

class CommunityReportTargetType {
  const CommunityReportTargetType._();

  static const post = 'post';
  static const comment = 'comment';
}
