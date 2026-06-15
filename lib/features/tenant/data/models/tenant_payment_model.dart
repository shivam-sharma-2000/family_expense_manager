import '../../domain/entities/tenant_payment_entity.dart';

class TenantPaymentModel extends TenantPaymentEntity {
  const TenantPaymentModel({
    required super.id,
    required super.tenantId,
    required super.billId,
    required super.date,
    required super.amount,
    required super.mode,
    super.notes,
    required super.userId,
    required super.familyId,
    super.isSynced,
    super.isDeleted,
  });

  factory TenantPaymentModel.fromMap(Map<String, dynamic> map) {
    return TenantPaymentModel(
      id: map['payment_id'] as String,
      tenantId: map['tenant_id'] as String,
      billId: map['bill_id'] as String? ?? '', // default to empty for old entries
      date: DateTime.fromMillisecondsSinceEpoch((map['payment_date'] as num).toInt()),
      amount: (map['amount'] as num).toDouble(),
      mode: map['payment_mode'] as String,
      notes: map['notes'] as String?,
      userId: map['user_id'] as String,
      familyId: map['family_id'] as String,
      isSynced: (map['is_synced'] as num?)?.toInt() == 1,
      isDeleted: (map['is_deleted'] as num?)?.toInt() == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'payment_id': id,
      'tenant_id': tenantId,
      'bill_id': billId,
      'payment_date': date.millisecondsSinceEpoch,
      'amount': amount,
      'payment_mode': mode,
      'notes': notes,
      'user_id': userId,
      'family_id': familyId,
      'is_synced': isSynced ? 1 : 0,
      'is_deleted': isDeleted ? 1 : 0,
    };
  }

  factory TenantPaymentModel.fromEntity(TenantPaymentEntity entity) {
    return TenantPaymentModel(
      id: entity.id,
      tenantId: entity.tenantId,
      billId: entity.billId,
      date: entity.date,
      amount: entity.amount,
      mode: entity.mode,
      notes: entity.notes,
      userId: entity.userId,
      familyId: entity.familyId,
      isSynced: entity.isSynced,
      isDeleted: entity.isDeleted,
    );
  }
}
