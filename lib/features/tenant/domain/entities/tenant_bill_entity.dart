import 'package:equatable/equatable.dart';

class TenantBillEntity extends Equatable {
  final String id;
  final String tenantId;
  final int month;
  final int year;
  final double rentAmount;
  final double electricityUnits;
  final double electricityAmount;
  final double maintenanceAmount;
  final double pendingAmount;
  final double previousDue;
  final double paidAmount;
  final double advanceAdjustment;
  final double totalAmount;
  final DateTime billDate;
  final String userId;
  final String familyId;
  final bool isSynced;
  final bool isDeleted;

  const TenantBillEntity({
    required this.id,
    required this.tenantId,
    required this.month,
    required this.year,
    required this.rentAmount,
    this.electricityUnits = 0,
    this.electricityAmount = 0,
    this.maintenanceAmount = 0,
    this.pendingAmount = 0,
    this.previousDue = 0,
    this.paidAmount = 0,
    this.advanceAdjustment = 0,
    required this.totalAmount,
    required this.billDate,
    required this.userId,
    required this.familyId,
    this.isSynced = false,
    this.isDeleted = false,
  });

  @override
  List<Object?> get props => [
        id,
        tenantId,
        month,
        year,
        rentAmount,
        electricityUnits,
        electricityAmount,
        maintenanceAmount,
        pendingAmount,
        previousDue,
        paidAmount,
        advanceAdjustment,
        totalAmount,
        billDate,
        userId,
        familyId,
        isSynced,
        isDeleted,
      ];

  TenantBillEntity copyWith({
    String? id,
    String? tenantId,
    int? month,
    int? year,
    double? rentAmount,
    double? electricityUnits,
    double? electricityAmount,
    double? maintenanceAmount,
    double? pendingAmount,
    double? previousDue,
    double? paidAmount,
    double? advanceAdjustment,
    double? totalAmount,
    DateTime? billDate,
    String? userId,
    String? familyId,
    bool? isSynced,
    bool? isDeleted,
  }) {
    return TenantBillEntity(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      month: month ?? this.month,
      year: year ?? this.year,
      rentAmount: rentAmount ?? this.rentAmount,
      electricityUnits: electricityUnits ?? this.electricityUnits,
      electricityAmount: electricityAmount ?? this.electricityAmount,
      maintenanceAmount: maintenanceAmount ?? this.maintenanceAmount,
      pendingAmount: pendingAmount ?? this.pendingAmount,
      previousDue: previousDue ?? this.previousDue,
      paidAmount: paidAmount ?? this.paidAmount,
      advanceAdjustment: advanceAdjustment ?? this.advanceAdjustment,
      totalAmount: totalAmount ?? this.totalAmount,
      billDate: billDate ?? this.billDate,
      userId: userId ?? this.userId,
      familyId: familyId ?? this.familyId,
      isSynced: isSynced ?? this.isSynced,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
