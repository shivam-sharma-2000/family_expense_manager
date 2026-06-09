import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final String? familyId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.familyId,
    this.photoUrl,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [id, name, email, photoUrl, createdAt, updatedAt, familyId];

  UserEntity copyWith({
    String? id,
    String? name,
    String? email,
    String? familyId,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      familyId: familyId ?? this.familyId,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
