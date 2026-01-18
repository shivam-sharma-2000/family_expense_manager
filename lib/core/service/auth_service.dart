import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../enums/user_role.dart';

abstract class AuthService {

  Future<UserRole> get currentRole;

  Future<void> initializeGoogleSignIn();

  Future<User?> signInWithGoogle();

  Future<User?> signInWithEmail({
    required String email,
    required String password,
  });

  Future<User?> registerWithEmail({
    required String email,
    required String password,
    String? familyId,
  });

  Future<void> signOut();
}
