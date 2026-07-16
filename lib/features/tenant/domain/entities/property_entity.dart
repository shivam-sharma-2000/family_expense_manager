import 'package:equatable/equatable.dart';

class PropertyEntity extends Equatable {
  final String id;
  final String name;
  final String ownerName;
  final String ownerPhone;
  final String? logoUrl;
  final double defaultElectricityRate;
  final DateTime createdAt;

  const PropertyEntity({
    required this.id,
    required this.name,
    required this.ownerName,
    required this.ownerPhone,
    this.logoUrl,
    required this.defaultElectricityRate,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        ownerName,
        ownerPhone,
        logoUrl,
        defaultElectricityRate,
        createdAt,
      ];

  PropertyEntity copyWith({
    String? id,
    String? name,
    String? ownerName,
    String? ownerPhone,
    String? logoUrl,
    double? defaultElectricityRate,
    DateTime? createdAt,
  }) {
    return PropertyEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      ownerName: ownerName ?? this.ownerName,
      ownerPhone: ownerPhone ?? this.ownerPhone,
      logoUrl: logoUrl ?? this.logoUrl,
      defaultElectricityRate: defaultElectricityRate ?? this.defaultElectricityRate,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
