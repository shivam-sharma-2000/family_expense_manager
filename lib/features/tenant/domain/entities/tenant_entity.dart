import 'package:equatable/equatable.dart';

class TenantEntity extends Equatable {
  final String id;
  final String propertyId;
  final String tenantCode; // TNT-0001
  final String name;
  final String phone;
  final String email;
  final String idNumber; // Aadhaar/ID
  final String roomNumber;
  final String floor;
  final double rent;
  final double deposit;
  final DateTime joiningDate;
  final DateTime agreementEndDate;
  final String status; // Active | Vacated
  final String photoUrl;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String userId; // Maintain user id for auth checks

  const TenantEntity({
    required this.id,
    required this.propertyId,
    required this.tenantCode,
    required this.name,
    required this.phone,
    required this.email,
    required this.idNumber,
    required this.roomNumber,
    required this.floor,
    required this.rent,
    required this.deposit,
    required this.joiningDate,
    required this.agreementEndDate,
    required this.status,
    required this.photoUrl,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
    required this.userId,
  });

  // Getter compatibility with previous mobile/aadhaar/photoPath/advance/rentStartDate/familyId properties
  String get mobile => phone;
  String get aadhaar => idNumber;
  String? get photoPath => photoUrl.isEmpty ? null : photoUrl;
  double get advance => deposit;
  DateTime get rentStartDate => joiningDate;
  String get familyId => propertyId;

  @override
  List<Object?> get props => [
        id,
        propertyId,
        tenantCode,
        name,
        phone,
        email,
        idNumber,
        roomNumber,
        floor,
        rent,
        deposit,
        joiningDate,
        agreementEndDate,
        status,
        photoUrl,
        notes,
        createdAt,
        updatedAt,
        userId,
      ];

  TenantEntity copyWith({
    String? id,
    String? propertyId,
    String? tenantCode,
    String? name,
    String? phone,
    String? email,
    String? idNumber,
    String? roomNumber,
    String? floor,
    double? rent,
    double? deposit,
    DateTime? joiningDate,
    DateTime? agreementEndDate,
    String? status,
    String? photoUrl,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userId,
  }) {
    return TenantEntity(
      id: id ?? this.id,
      propertyId: propertyId ?? this.propertyId,
      tenantCode: tenantCode ?? this.tenantCode,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      idNumber: idNumber ?? this.idNumber,
      roomNumber: roomNumber ?? this.roomNumber,
      floor: floor ?? this.floor,
      rent: rent ?? this.rent,
      deposit: deposit ?? this.deposit,
      joiningDate: joiningDate ?? this.joiningDate,
      agreementEndDate: agreementEndDate ?? this.agreementEndDate,
      status: status ?? this.status,
      photoUrl: photoUrl ?? this.photoUrl,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userId: userId ?? this.userId,
    );
  }
}
