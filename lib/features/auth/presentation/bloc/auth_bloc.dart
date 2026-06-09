import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/auth_repositories.dart';

part 'auth_event.dart';

part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repository;

  AuthBloc(this.repository) : super(const LoginInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
    on<GoogleLoginSubmitted>(_onGoogleLoginSubmitted);
    on<RegisterUserEvent>(_onRegisterUser);
    on<TogglePasswordVisibility>(_onTogglePasswordVisibility);
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final user = await repository.login(
        email: event.email,
        password: event.password,
      );

      if (user == null) {
        emit(const AuthFailure(message: 'Invalid email or password'));
        return;
      }

      emit(AuthSuccess());
    } catch (e) {
      emit(AuthFailure(message: e.toString()));
    }
  }

  Future<void> _onGoogleLoginSubmitted(
    GoogleLoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final user = await repository.googleLogin();

      if (user == null) {
        emit(const AuthFailure(message: 'Google login failed'));
        return;
      }

      emit(AuthSuccess());
    } catch (e) {
      emit(AuthFailure(message: e.toString()));
    }
  }

  void _onTogglePasswordVisibility(
    TogglePasswordVisibility event,
    Emitter<AuthState> emit,
  ) {
    emit(const LoginInitial());
  }

  Future<void> _onRegisterUser(
    RegisterUserEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final user = await repository.register(
        name: event.name,
        email: event.email,
        password: event.password,
        phone: event.phone,
        familyId: event.familyId!,
      );

      if (user == null) {
        emit(const AuthFailure(message: "User registration failed"));
        return;
      }

      emit(AuthSuccess());
    } catch (e) {
      emit(AuthFailure(message: e.toString()));
    }
  }
}
