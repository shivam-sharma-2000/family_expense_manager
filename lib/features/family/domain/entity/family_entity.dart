class Family {
  final String id;
  final String familyCode;
  final String familyName;
  final String createdByUserId;
  final DateTime createdAt;

  const Family({
    required this.id,
    required this.familyCode,
    required this.familyName,
    required this.createdByUserId,
    required this.createdAt,
  });
}