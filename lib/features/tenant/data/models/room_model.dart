import '../../domain/entities/room_entity.dart';

class RoomModel extends RoomEntity {
  const RoomModel({
    required super.id,
    required super.propertyId,
    required super.number,
    required super.floor,
    required super.capacity,
    required super.rent,
    required super.status,
  });

  factory RoomModel.fromMap(String id, Map<String, dynamic> map) {
    return RoomModel(
      id: id,
      propertyId: map['propertyId'] as String? ?? '',
      number: map['number'] as String? ?? '',
      floor: map['floor'] as String? ?? '',
      capacity: (map['capacity'] as num? ?? 1).toInt(),
      rent: (map['rent'] as num? ?? 0.0).toDouble(),
      status: map['status'] as String? ?? 'Vacant',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'propertyId': propertyId,
      'number': number,
      'floor': floor,
      'capacity': capacity,
      'rent': rent,
      'status': status,
    };
  }

  factory RoomModel.fromEntity(RoomEntity entity) {
    return RoomModel(
      id: entity.id,
      propertyId: entity.propertyId,
      number: entity.number,
      floor: entity.floor,
      capacity: entity.capacity,
      rent: entity.rent,
      status: entity.status,
    );
  }
}
