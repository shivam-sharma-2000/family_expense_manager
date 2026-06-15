import '../../domain/entities/tenant_entity.dart';

class TenantModel extends TenantEntity {
  const TenantModel({
    required super.id,
    required super.name,
    required super.mobile,
    super.aadhaar,
    required super.familyMembers,
    required super.roomNumber,
    super.photoPath,
    required super.rent,
    required super.maintenance,
    required super.advance,
    required super.rentStartDate,
    required super.rentDueDate,
    required super.status,
    super.meterNumber,
    required super.previousReading,
    required super.unitRate,
    required super.userId,
    required super.familyId,
    super.isSynced,
    super.isDeleted,
  });

  factory TenantModel.fromMap(Map<String, dynamic> map) {
    return TenantModel(
      id: map['id'] as String,
      name: map['name'] as String,
      mobile: map['mobile'] as String,
      aadhaar: map['aadhaar'] as String?,
      familyMembers: (map['family_members'] as num).toInt(),
      roomNumber: map['room_number'] as String,
      photoPath: map['photo_path'] as String?,
      rent: (map['rent'] as num).toDouble(),
      maintenance: (map['maintenance'] as num).toDouble(),
      advance: (map['advance'] as num).toDouble(),
      rentStartDate: DateTime.fromMillisecondsSinceEpoch((map['rent_start_date'] as num).toInt()),
      rentDueDate: (map['rent_due_date'] as num).toInt(),
      status: map['status'] == 'vacated' ? TenantStatus.vacated : TenantStatus.active,
      meterNumber: map['meter_number'] as String?,
      previousReading: (map['previous_reading'] as num).toDouble(),
      unitRate: (map['unit_rate'] as num).toDouble(),
      userId: map['user_id'] as String,
      familyId: map['family_id'] as String,
      isSynced: (map['is_synced'] as num?)?.toInt() == 1,
      isDeleted: (map['is_deleted'] as num?)?.toInt() == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'mobile': mobile,
      'aadhaar': aadhaar,
      'family_members': familyMembers,
      'room_number': roomNumber,
      'photo_path': photoPath,
      'rent': rent,
      'maintenance': maintenance,
      'advance': advance,
      'rent_start_date': rentStartDate.millisecondsSinceEpoch,
      'rent_due_date': rentDueDate,
      'status': status == TenantStatus.active ? 'active' : 'vacated',
      'meter_number': meterNumber,
      'previous_reading': previousReading,
      'unit_rate': unitRate,
      'user_id': userId,
      'family_id': familyId,
      'is_synced': isSynced ? 1 : 0,
      'is_deleted': isDeleted ? 1 : 0,
    };
  }

  factory TenantModel.fromEntity(TenantEntity entity) {
    return TenantModel(
      id: entity.id,
      name: entity.name,
      mobile: entity.mobile,
      aadhaar: entity.aadhaar,
      familyMembers: entity.familyMembers,
      roomNumber: entity.roomNumber,
      photoPath: entity.photoPath,
      rent: entity.rent,
      maintenance: entity.maintenance,
      advance: entity.advance,
      rentStartDate: entity.rentStartDate,
      rentDueDate: entity.rentDueDate,
      status: entity.status,
      meterNumber: entity.meterNumber,
      previousReading: entity.previousReading,
      unitRate: entity.unitRate,
      userId: entity.userId,
      familyId: entity.familyId,
      isSynced: entity.isSynced,
      isDeleted: entity.isDeleted,
    );
  }
}
