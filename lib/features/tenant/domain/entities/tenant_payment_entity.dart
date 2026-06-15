import 'package:equatable/equatable.dart';

class TenantPaymentEntity extends Equatable {
  final String id;
  final String tenantId;
  final String billId;
  final DateTime date;
  final double amount;
  final String mode; // Cash, UPI, Bank Transfer
  final String? notes;
  final String userId;
  final String familyId;
  final bool isSynced;
  final bool isDeleted;

  const TenantPaymentEntity({
    required this.id,
    required this.tenantId,
    required this.billId,
    required this.date,
    required this.amount,
    required this.mode,
    this.notes,
    required this.userId,
    required this.familyId,
    this.isSynced = false,
    this.isDeleted = false,
  });

  @override
  List<Object?> get props => [
        id,
        tenantId,
        billId,
        date,
        amount,
        mode,
        notes,
        userId,
        familyId,
        isSynced,
        isDeleted,
      ];
}
