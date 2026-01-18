part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoginSubmitted extends AuthEvent {
  final String email;
  final String password;

  LoginSubmitted({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class GoogleLoginSubmitted extends AuthEvent {}

class TogglePasswordVisibility extends AuthEvent {}

class RegisterUserEvent extends AuthEvent {
  final String name;
  final String email;
  final String phone;
  final String? familyId;
  final String password;

  RegisterUserEvent({
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    this.familyId,
  });
}
