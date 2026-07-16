import 'package:equatable/equatable.dart';

class RoomEntity extends Equatable {
  final String id;
  final String propertyId;
  final String number;
  final String floor;
  final int capacity;
  final double rent;
  final String status; // Occupied | Vacant

  const RoomEntity({
    required this.id,
    required this.propertyId,
    required this.number,
    required this.floor,
    required this.capacity,
    required this.rent,
    required this.status,
  });

  @override
  List<Object?> get props => [
        id,
        propertyId,
        number,
        floor,
        capacity,
        rent,
        status,
      ];

  RoomEntity copyWith({
    String? id,
    String? propertyId,
    String? number,
    String? floor,
    int? capacity,
    double? rent,
    String? status,
  }) {
    return RoomEntity(
      id: id ?? this.id,
      propertyId: propertyId ?? this.propertyId,
      number: number ?? this.number,
      floor: floor ?? this.floor,
      capacity: capacity ?? this.capacity,
      rent: rent ?? this.rent,
      status: status ?? this.status,
    );
  }
}
