import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/tenant_bill_entity.dart';

class TenantBillModel extends TenantBillEntity {
  const TenantBillModel({
    required super.id,
    required super.propertyId,
    required super.billNumber,
    required super.tenantId,
    required super.tenantName,
    required super.roomNumber,
    required super.month,
    required super.dueDate,
    required super.createdDate,
    required super.rent,
    required super.electricityUnits,
    required super.electricityRate,
    required super.electricity,
    required super.maintenance,
    required super.other,
    required super.previousDue,
    required super.advanceAdjustment,
    required super.discount,
    required super.total,
    required super.status,
    required super.notes,
    required super.pdfUrl,
    required super.createdAt,
    required super.updatedAt,
    required super.userId,
  });

  factory TenantBillModel.fromMap(String id, Map<String, dynamic> map) {
    return TenantBillModel(
      id: id,
      propertyId: map['propertyId'] as String? ?? map['family_id'] as String? ?? '',
      billNumber: map['billNumber'] as String? ?? '',
      tenantId: map['tenantId'] as String? ?? map['tenant_id'] as String? ?? '',
      tenantName: map['tenantName'] as String? ?? map['tenant_name'] as String? ?? '',
      roomNumber: map['roomNumber'] as String? ?? map['room_number'] as String? ?? '',
      month: map['month'] as String? ?? '',
      dueDate: map['dueDate'] is Timestamp
          ? (map['dueDate'] as Timestamp).toDate()
          : map['bill_date'] is num
              ? DateTime.fromMillisecondsSinceEpoch((map['bill_date'] as num).toInt())
              : DateTime.now(),
      createdDate: map['createdDate'] is Timestamp
          ? (map['createdDate'] as Timestamp).toDate()
          : map['bill_date'] is num
              ? DateTime.fromMillisecondsSinceEpoch((map['bill_date'] as num).toInt())
              : DateTime.now(),
      rent: (map['rent'] as num? ?? map['rent_amount'] as num? ?? 0.0).toDouble(),
      electricityUnits: (map['electricityUnits'] as num? ?? map['electricity_units'] as num? ?? 0.0).toDouble(),
      electricityRate: (map['electricityRate'] as num? ?? map['unit_rate'] as num? ?? 0.0).toDouble(),
      electricity: (map['electricity'] as num? ?? map['electricity_amount'] as num? ?? 0.0).toDouble(),
      maintenance: (map['maintenance'] as num? ?? map['maintenance_amount'] as num? ?? 0.0).toDouble(),
      other: (map['other'] as num? ?? 0.0).toDouble(),
      previousDue: (map['previousDue'] as num? ?? map['previous_due'] as num? ?? 0.0).toDouble(),
      advanceAdjustment: (map['advanceAdjustment'] as num? ?? map['advance_adjustment'] as num? ?? 0.0).toDouble(),
      discount: (map['discount'] as num? ?? 0.0).toDouble(),
      total: (map['total'] as num? ?? map['total_amount'] as num? ?? 0.0).toDouble(),
      status: map['status'] as String? ?? 'Unpaid',
      notes: map['notes'] as String? ?? '',
      pdfUrl: map['pdfUrl'] as String? ?? '',
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
      'billNumber': billNumber,
      'tenantId': tenantId,
      'tenantName': tenantName,
      'roomNumber': roomNumber,
      'month': month,
      'dueDate': Timestamp.fromDate(dueDate),
      'createdDate': Timestamp.fromDate(createdDate),
      'rent': rent,
      'electricityUnits': electricityUnits,
      'electricityRate': electricityRate,
      'electricity': electricity,
      'maintenance': maintenance,
      'other': other,
      'previousDue': previousDue,
      'advanceAdjustment': advanceAdjustment,
      'discount': discount,
      'total': total,
      'status': status,
      'notes': notes,
      'pdfUrl': pdfUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'userId': userId,
    };
  }

  factory TenantBillModel.fromEntity(TenantBillEntity entity) {
    return TenantBillModel(
      id: entity.id,
      propertyId: entity.propertyId,
      billNumber: entity.billNumber,
      tenantId: entity.tenantId,
      tenantName: entity.tenantName,
      roomNumber: entity.roomNumber,
      month: entity.month,
      dueDate: entity.dueDate,
      createdDate: entity.createdDate,
      rent: entity.rent,
      electricityUnits: entity.electricityUnits,
      electricityRate: entity.electricityRate,
      electricity: entity.electricity,
      maintenance: entity.maintenance,
      other: entity.other,
      previousDue: entity.previousDue,
      advanceAdjustment: entity.advanceAdjustment,
      discount: entity.discount,
      total: entity.total,
      status: entity.status,
      notes: entity.notes,
      pdfUrl: entity.pdfUrl,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      userId: entity.userId,
    );
  }
}
