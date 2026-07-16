import 'package:equatable/equatable.dart';

class TenantBillEntity extends Equatable {
  final String id;
  final String propertyId;
  final String billNumber; // e.g., BILL-2026-0001
  final String tenantId;
  final String tenantName; // Denormalized
  final String roomNumber; // Denormalized
  final String month; // YYYY-MM
  final DateTime dueDate;
  final DateTime createdDate;
  final double rent;
  final double electricityUnits;
  final double electricityRate;
  final double electricity;
  final double maintenance;
  final double other;
  final double previousDue;
  final double advanceAdjustment;
  final double discount;
  final double total;
  final String status; // Unpaid | Partially Paid | Paid
  final String notes;
  final String pdfUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String userId;

  const TenantBillEntity({
    required this.id,
    required this.propertyId,
    required this.billNumber,
    required this.tenantId,
    required this.tenantName,
    required this.roomNumber,
    required this.month,
    required this.dueDate,
    required this.createdDate,
    required this.rent,
    required this.electricityUnits,
    required this.electricityRate,
    required this.electricity,
    required this.maintenance,
    required this.other,
    required this.previousDue,
    required this.advanceAdjustment,
    required this.discount,
    required this.total,
    required this.status,
    required this.notes,
    required this.pdfUrl,
    required this.createdAt,
    required this.updatedAt,
    required this.userId,
  });

  // Getter compatibility with previous bill amount properties
  double get rentAmount => rent;
  double get electricityAmount => electricity;
  double get maintenanceAmount => maintenance;
  double get totalAmount => total;
  double get paidAmount => total - pendingAmount;
  double get pendingAmount => status == 'Paid' ? 0.0 : total; // Simplification or customized below
  DateTime get billDate => createdDate;
  String get familyId => propertyId;

  @override
  List<Object?> get props => [
        id,
        propertyId,
        billNumber,
        tenantId,
        tenantName,
        roomNumber,
        month,
        dueDate,
        createdDate,
        rent,
        electricityUnits,
        electricityRate,
        electricity,
        maintenance,
        other,
        previousDue,
        advanceAdjustment,
        discount,
        total,
        status,
        notes,
        pdfUrl,
        createdAt,
        updatedAt,
        userId,
      ];

  TenantBillEntity copyWith({
    String? id,
    String? propertyId,
    String? billNumber,
    String? tenantId,
    String? tenantName,
    String? roomNumber,
    String? month,
    DateTime? dueDate,
    DateTime? createdDate,
    double? rent,
    double? electricityUnits,
    double? electricityRate,
    double? electricity,
    double? maintenance,
    double? other,
    double? previousDue,
    double? advanceAdjustment,
    double? discount,
    double? total,
    String? status,
    String? notes,
    String? pdfUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userId,
  }) {
    return TenantBillEntity(
      id: id ?? this.id,
      propertyId: propertyId ?? this.propertyId,
      billNumber: billNumber ?? this.billNumber,
      tenantId: tenantId ?? this.tenantId,
      tenantName: tenantName ?? this.tenantName,
      roomNumber: roomNumber ?? this.roomNumber,
      month: month ?? this.month,
      dueDate: dueDate ?? this.dueDate,
      createdDate: createdDate ?? this.createdDate,
      rent: rent ?? this.rent,
      electricityUnits: electricityUnits ?? this.electricityUnits,
      electricityRate: electricityRate ?? this.electricityRate,
      electricity: electricity ?? this.electricity,
      maintenance: maintenance ?? this.maintenance,
      other: other ?? this.other,
      previousDue: previousDue ?? this.previousDue,
      advanceAdjustment: advanceAdjustment ?? this.advanceAdjustment,
      discount: discount ?? this.discount,
      total: total ?? this.total,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      pdfUrl: pdfUrl ?? this.pdfUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userId: userId ?? this.userId,
    );
  }
}
