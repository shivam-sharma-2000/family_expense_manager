import 'package:equatable/equatable.dart';

class TenantPaymentEntity extends Equatable {
  final String id;
  final String propertyId;
  final String billId;
  final String tenantId;
  final double amount;
  final DateTime date;
  final String method; // Cash | UPI | Bank Transfer
  final String transactionId;
  final DateTime createdAt;
  final String userId;

  const TenantPaymentEntity({
    required this.id,
    required this.propertyId,
    required this.billId,
    required this.tenantId,
    required this.amount,
    required this.date,
    required this.method,
    required this.transactionId,
    required this.createdAt,
    required this.userId,
  });

  // Getter compatibility with previous fields
  String get mode => method;
  String get notes => transactionId;
  String get familyId => propertyId;

  @override
  List<Object?> get props => [
        id,
        propertyId,
        billId,
        tenantId,
        amount,
        date,
        method,
        transactionId,
        createdAt,
        userId,
      ];

  TenantPaymentEntity copyWith({
    String? id,
    String? propertyId,
    String? billId,
    String? tenantId,
    double? amount,
    DateTime? date,
    String? method,
    String? transactionId,
    DateTime? createdAt,
    String? userId,
  }) {
    return TenantPaymentEntity(
      id: id ?? this.id,
      propertyId: propertyId ?? this.propertyId,
      billId: billId ?? this.billId,
      tenantId: tenantId ?? this.tenantId,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      method: method ?? this.method,
      transactionId: transactionId ?? this.transactionId,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
    );
  }
}
