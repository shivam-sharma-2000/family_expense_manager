import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/tenant_entity.dart';

class TenantModel extends TenantEntity {
  const TenantModel({
    required super.id,
    required super.propertyId,
    required super.tenantCode,
    required super.name,
    required super.phone,
    required super.email,
    required super.idNumber,
    required super.roomNumber,
    required super.floor,
    required super.rent,
    required super.deposit,
    required super.joiningDate,
    required super.agreementEndDate,
    required super.status,
    required super.photoUrl,
    required super.notes,
    required super.createdAt,
    required super.updatedAt,
    required super.userId,
  });

  factory TenantModel.fromMap(String id, Map<String, dynamic> map) {
    return TenantModel(
      id: id,
      propertyId: map['propertyId'] as String? ?? map['family_id'] as String? ?? '',
      tenantCode: map['tenantCode'] as String? ?? '',
      name: map['name'] as String? ?? '',
      phone: map['phone'] as String? ?? map['mobile'] as String? ?? '',
      email: map['email'] as String? ?? '',
      idNumber: map['idNumber'] as String? ?? map['aadhaar'] as String? ?? '',
      roomNumber: map['roomNumber'] as String? ?? map['room_number'] as String? ?? '',
      floor: map['floor'] as String? ?? '',
      rent: (map['rent'] as num? ?? 0.0).toDouble(),
      deposit: (map['deposit'] as num? ?? map['advance'] as num? ?? 0.0).toDouble(),
      joiningDate: map['joiningDate'] is Timestamp
          ? (map['joiningDate'] as Timestamp).toDate()
          : map['rent_start_date'] is num
              ? DateTime.fromMillisecondsSinceEpoch((map['rent_start_date'] as num).toInt())
              : DateTime.now(),
      agreementEndDate: map['agreementEndDate'] is Timestamp
          ? (map['agreementEndDate'] as Timestamp).toDate()
          : DateTime.now().add(const Duration(days: 365)),
      status: map['status'] as String? ?? 'Active',
      photoUrl: map['photoUrl'] as String? ?? map['photo_path'] as String? ?? '',
      notes: map['notes'] as String? ?? '',
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: map['updatedAt'] is Timestamp
          ? (map['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
      userId: map['userId'] as String? ?? map['user_id'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'propertyId': propertyId,
      'tenantCode': tenantCode,
      'name': name,
      'phone': phone,
      'email': email,
      'idNumber': idNumber,
      'roomNumber': roomNumber,
      'floor': floor,
      'rent': rent,
      'deposit': deposit,
      'joiningDate': Timestamp.fromDate(joiningDate),
      'agreementEndDate': Timestamp.fromDate(agreementEndDate),
      'status': status,
      'photoUrl': photoUrl,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'userId': userId,
    };
  }

  factory TenantModel.fromEntity(TenantEntity entity) {
    return TenantModel(
      id: entity.id,
      propertyId: entity.propertyId,
      tenantCode: entity.tenantCode,
      name: entity.name,
      phone: entity.phone,
      email: entity.email,
      idNumber: entity.idNumber,
      roomNumber: entity.roomNumber,
      floor: entity.floor,
      rent: entity.rent,
      deposit: entity.deposit,
      joiningDate: entity.joiningDate,
      agreementEndDate: entity.agreementEndDate,
      status: entity.status,
      photoUrl: entity.photoUrl,
      notes: entity.notes,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      userId: entity.userId,
    );
  }
}
