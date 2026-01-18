import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:expense_manager/core/service/impl/auth_service_impl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/service/auth_service.dart';

part 'auth_event.dart';

part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthServiceImpl _authService;
  final FirebaseFirestore _firestore;

  AuthBloc(this._authService, this._firestore) : super(const LoginInitial()) {
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
      final user = await _authService.signInWithEmail(
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
      final user = await _authService.signInWithGoogle();
      if (user == null) {
        emit(const AuthFailure(message: 'Google login failed'));
        return;
      }

      // Save user data to Firestore
      _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': user.displayName,
        'email': user.email,
        'photoUrl': user.photoURL ?? '',
        'lastLogin': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

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
      final user = await _authService.registerWithEmail(
        email: event.email,
        password: event.password,
      );

      if (user == null) {
        emit(const AuthFailure(message: "User registration failed"));
        return;
      }


      // Save user data to Firestore
      final res = await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': event.name,
        'email': event.email,
        'phoneNumber': event.phone,
        'familyId': event.familyId,
        'photoUrl': user.photoURL ?? '',
        'lastLogin': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      emit(AuthSuccess());
    } catch (e) {
      emit(AuthFailure(message: e.toString()));
    }
  }
}
