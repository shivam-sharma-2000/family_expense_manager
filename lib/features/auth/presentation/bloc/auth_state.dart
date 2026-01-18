part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class LoginInitial extends AuthState {
  const LoginInitial() : super();
}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {}

class AuthFailure extends AuthState {
  final String message;

  const AuthFailure({required this.message}) : super();

  @override
  List<Object?> get props => [message];
}
