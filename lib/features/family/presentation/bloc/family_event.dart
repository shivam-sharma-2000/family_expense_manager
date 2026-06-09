import 'package:equatable/equatable.dart';

abstract class FamilyEvent extends Equatable {
  const FamilyEvent();

  @override
  List<Object?> get props => [];
}

class CreateFamilyEvent extends FamilyEvent {
  final String familyName;
  final String userId;

  const CreateFamilyEvent({required this.familyName, required this.userId});

  @override
  List<Object?> get props => [familyName, userId];
}
