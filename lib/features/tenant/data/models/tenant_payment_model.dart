import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/tenant_payment_entity.dart';

class TenantPaymentModel extends TenantPaymentEntity {
  const TenantPaymentModel({
    required super.id,
    required super.propertyId,
    required super.billId,
    required super.tenantId,
    required super.amount,
    required super.date,
    required super.method,
    required super.transactionId,
    required super.createdAt,
    required super.userId,
  });

  factory TenantPaymentModel.fromMap(String id, Map<String, dynamic> map) {
    return TenantPaymentModel(
      id: id,
      propertyId: map['propertyId'] as String? ?? map['family_id'] as String? ?? '',
      billId: map['billId'] as String? ?? map['bill_id'] as String? ?? '',
      tenantId: map['tenantId'] as String? ?? map['tenant_id'] as String? ?? '',
      amount: (map['amount'] as num? ?? 0.0).toDouble(),
      date: map['date'] is Timestamp
          ? (map['date'] as Timestamp).toDate()
          : map['date'] is num
              ? DateTime.fromMillisecondsSinceEpoch((map['date'] as num).toInt())
              : DateTime.now(),
      method: map['method'] as String? ?? map['mode'] as String? ?? 'Cash',
      transactionId: map['transactionId'] as String? ?? map['notes'] as String? ?? '',
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      userId: map['userId'] as String? ?? map['user_id'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'propertyId': propertyId,
      'billId': billId,
      'tenantId': tenantId,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'method': method,
      'transactionId': transactionId,
      'createdAt': Timestamp.fromDate(createdAt),
      'userId': userId,
    };
  }

  factory TenantPaymentModel.fromEntity(TenantPaymentEntity entity) {
    return TenantPaymentModel(
      id: entity.id,
      propertyId: entity.propertyId,
      billId: entity.billId,
      tenantId: entity.tenantId,
      amount: entity.amount,
      date: entity.date,
      method: entity.method,
      transactionId: entity.transactionId,
      createdAt: entity.createdAt,
      userId: entity.userId,
    );
  }
}
