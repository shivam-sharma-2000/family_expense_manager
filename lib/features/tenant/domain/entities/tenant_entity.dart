import 'package:equatable/equatable.dart';

enum TenantStatus { active, vacated }

class TenantEntity extends Equatable {
  final String id;
  final String name;
  final String mobile;
  final String? aadhaar;
  final int familyMembers;
  final String roomNumber;
  final String? photoPath;
  final double rent;
  final double maintenance;
  final double advance;
  final DateTime rentStartDate;
  final int rentDueDate;
  final TenantStatus status;
  final String? meterNumber;
  final double previousReading;
  final double unitRate;
  final String userId;
  final String familyId;
  final bool isSynced;
  final bool isDeleted;

  const TenantEntity({
    required this.id,
    required this.name,
    required this.mobile,
    this.aadhaar,
    required this.familyMembers,
    required this.roomNumber,
    this.photoPath,
    required this.rent,
    required this.maintenance,
    required this.advance,
    required this.rentStartDate,
    required this.rentDueDate,
    required this.status,
    this.meterNumber,
    required this.previousReading,
    required this.unitRate,
    required this.userId,
    required this.familyId,
    this.isSynced = false,
    this.isDeleted = false,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    mobile,
    aadhaar,
    familyMembers,
    roomNumber,
    photoPath,
    rent,
    maintenance,
    advance,
    rentStartDate,
    rentDueDate,
    status,
    meterNumber,
    previousReading,
    unitRate,
    userId,
    familyId,
    isSynced,
    isDeleted,
  ];

  TenantEntity copyWith({
    String? id,
    String? name,
    String? mobile,
    String? aadhaar,
    int? familyMembers,
    String? roomNumber,
    String? photoPath,
    double? rent,
    double? maintenance,
    double? advance,
    DateTime? rentStartDate,
    int? rentDueDate,
    TenantStatus? status,
    String? meterNumber,
    double? previousReading,
    double? unitRate,
    String? userId,
    String? familyId,
    bool? isSynced,
    bool? isDeleted,
  }) {
    return TenantEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      mobile: mobile ?? this.mobile,
      aadhaar: aadhaar ?? this.aadhaar,
      familyMembers: familyMembers ?? this.familyMembers,
      roomNumber: roomNumber ?? this.roomNumber,
      photoPath: photoPath ?? this.photoPath,
      rent: rent ?? this.rent,
      maintenance: maintenance ?? this.maintenance,
      advance: advance ?? this.advance,
      rentStartDate: rentStartDate ?? this.rentStartDate,
      rentDueDate: rentDueDate ?? this.rentDueDate,
      status: status ?? this.status,
      meterNumber: meterNumber ?? this.meterNumber,
      previousReading: previousReading ?? this.previousReading,
      unitRate: unitRate ?? this.unitRate,
      userId: userId ?? this.userId,
      familyId: familyId ?? this.familyId,
      isSynced: isSynced ?? this.isSynced,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
