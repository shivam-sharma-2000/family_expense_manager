import '../../domain/entity/family_entity.dart';

class FamilyModel {
  final String id;
  final String familyCode;
  final String familyName;
  final String createdByUserId;
  final DateTime createdAt;

  const FamilyModel({
    required this.id,
    required this.familyCode,
    required this.familyName,
    required this.createdByUserId,
    required this.createdAt,
  });

  factory FamilyModel.fromJson(Map<String, dynamic> json) {
    return FamilyModel(
      id: json['id'] as String,
      familyCode: json['familyCode'] as String,
      familyName: json['familyName'] as String,
      createdByUserId: json['createdByUserId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'familyCode': familyCode,
      'familyName': familyName,
      'createdByUserId': createdByUserId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory FamilyModel.fromEntity(Family family) {
    return FamilyModel(
      id: family.id,
      familyCode: family.familyCode,
      familyName: family.familyName,
      createdByUserId: family.createdByUserId,
      createdAt: family.createdAt,
    );
  }
}
