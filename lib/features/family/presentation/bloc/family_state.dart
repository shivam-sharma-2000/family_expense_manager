import 'package:equatable/equatable.dart';
import 'package:expense_manager/features/family/domain/entity/family_entity.dart';

abstract class FamilyState extends Equatable {
  const FamilyState();
  
  @override
  List<Object?> get props => [];
}

class FamilyInitial extends FamilyState {}

class FamilyLoading extends FamilyState {}

class FamilyCreatedSuccess extends FamilyState {
  final Family family;
  const FamilyCreatedSuccess(this.family);

  @override
  List<Object?> get props => [family];
}

class FamilyError extends FamilyState {
  final String message;
  const FamilyError(this.message);

  @override
  List<Object?> get props => [message];
}
