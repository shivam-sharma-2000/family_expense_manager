import 'package:equatable/equatable.dart';
import 'package:expense_manager/features/user/domain/entities/user_entity.dart';

// Events
abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object?> get props => [];
}

class LoadUserEvent extends UserEvent {
  final String userId;

  const LoadUserEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

class UpdateUserProfileEvent extends UserEvent {
  final String userId;
  final String? name;
  final String? photoUrl;

  const UpdateUserProfileEvent({
    required this.userId,
    this.name,
    this.photoUrl,
  });

  @override
  List<Object?> get props => [userId, name, photoUrl];
}

class UserErrorEvent extends UserEvent {
  final String message;

  const UserErrorEvent(this.message);

  @override
  List<Object?> get props => [message];
}
