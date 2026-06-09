import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRepository {
  Future<User?> login({
    required String email,
    required String password,
  });

  Future<User?> googleLogin();

  Future<User?> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String familyId,
  });
}