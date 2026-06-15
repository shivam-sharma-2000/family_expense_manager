import '../../domain/entities/tenant_bill_entity.dart';

class TenantBillModel extends TenantBillEntity {
  const TenantBillModel({
    required super.id,
    required super.tenantId,
    required super.month,
    required super.year,
    required super.rentAmount,
    super.electricityUnits,
    super.electricityAmount,
    super.maintenanceAmount,
    super.pendingAmount,
    super.previousDue,
    super.paidAmount,
    super.advanceAdjustment,
    required super.totalAmount,
    required super.billDate,
    required super.userId,
    required super.familyId,
    super.isSynced,
    super.isDeleted,
  });

  factory TenantBillModel.fromMap(Map<String, dynamic> map) {
    return TenantBillModel(
      id: map['bill_id'] as String,
      tenantId: map['tenant_id'] as String,
      month: (map['month'] as num).toInt(),
      year: (map['year'] as num).toInt(),
      rentAmount: (map['rent_amount'] as num).toDouble(),
      electricityUnits: (map['electricity_units'] as num).toDouble(),
      electricityAmount: (map['electricity_amount'] as num).toDouble(),
      maintenanceAmount: (map['maintenance_amount'] as num).toDouble(),
      pendingAmount: (map['pending_amount'] as num).toDouble(),
      previousDue: (map['previous_due'] as num?)?.toDouble() ?? 0.0,
      paidAmount: (map['paid_amount'] as num?)?.toDouble() ?? 0.0,
      advanceAdjustment: (map['advance_adjustment'] as num).toDouble(),
      totalAmount: (map['total_amount'] as num).toDouble(),
      billDate: DateTime.fromMillisecondsSinceEpoch((map['bill_date'] as num).toInt()),
      userId: map['user_id'] as String,
      familyId: map['family_id'] as String,
      isSynced: (map['is_synced'] as num?)?.toInt() == 1,
      isDeleted: (map['is_deleted'] as num?)?.toInt() == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bill_id': id,
      'tenant_id': tenantId,
      'month': month,
      'year': year,
      'rent_amount': rentAmount,
      'electricity_units': electricityUnits,
      'electricity_amount': electricityAmount,
      'maintenance_amount': maintenanceAmount,
      'pending_amount': pendingAmount,
      'previous_due': previousDue,
      'paid_amount': paidAmount,
      'advance_adjustment': advanceAdjustment,
      'total_amount': totalAmount,
      'bill_date': billDate.millisecondsSinceEpoch,
      'user_id': userId,
      'family_id': familyId,
      'is_synced': isSynced ? 1 : 0,
      'is_deleted': isDeleted ? 1 : 0,
    };
  }

  factory TenantBillModel.fromEntity(TenantBillEntity entity) {
    return TenantBillModel(
      id: entity.id,
      tenantId: entity.tenantId,
      month: entity.month,
      year: entity.year,
      rentAmount: entity.rentAmount,
      electricityUnits: entity.electricityUnits,
      electricityAmount: entity.electricityAmount,
      maintenanceAmount: entity.maintenanceAmount,
      pendingAmount: entity.pendingAmount,
      previousDue: entity.previousDue,
      paidAmount: entity.paidAmount,
      advanceAdjustment: entity.advanceAdjustment,
      totalAmount: entity.totalAmount,
      billDate: entity.billDate,
      userId: entity.userId,
      familyId: entity.familyId,
      isSynced: entity.isSynced,
      isDeleted: entity.isDeleted,
    );
  }
}
