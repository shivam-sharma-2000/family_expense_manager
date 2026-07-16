import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/property_entity.dart';

class PropertyModel extends PropertyEntity {
  const PropertyModel({
    required super.id,
    required super.name,
    required super.ownerName,
    required super.ownerPhone,
    super.logoUrl,
    required super.defaultElectricityRate,
    required super.createdAt,
  });

  factory PropertyModel.fromMap(String id, Map<String, dynamic> map) {
    return PropertyModel(
      id: id,
      name: map['name'] as String? ?? '',
      ownerName: map['ownerName'] as String? ?? '',
      ownerPhone: map['ownerPhone'] as String? ?? '',
      logoUrl: map['logoUrl'] as String?,
      defaultElectricityRate: (map['defaultElectricityRate'] as num? ?? 0.0).toDouble(),
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : map['createdAt'] is num
              ? DateTime.fromMillisecondsSinceEpoch((map['createdAt'] as num).toInt())
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'ownerName': ownerName,
      'ownerPhone': ownerPhone,
      'logoUrl': logoUrl,
      'defaultElectricityRate': defaultElectricityRate,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory PropertyModel.fromEntity(PropertyEntity entity) {
    return PropertyModel(
      id: entity.id,
      name: entity.name,
      ownerName: entity.ownerName,
      ownerPhone: entity.ownerPhone,
      logoUrl: entity.logoUrl,
      defaultElectricityRate: entity.defaultElectricityRate,
      createdAt: entity.createdAt,
    );
  }
}
