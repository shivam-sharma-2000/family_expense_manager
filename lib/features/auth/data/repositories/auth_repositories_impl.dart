import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/service/impl/auth_service_impl.dart';
import '../../domain/repositories/auth_repositories.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthServiceImpl authService;
  final FirebaseFirestore firestore;

  AuthRepositoryImpl({
    required this.authService,
    required this.firestore,
  });

  @override
  Future<User?> login({
    required String email,
    required String password,
  }) async {
    return await authService.signInWithEmail(
      email: email,
      password: password,
    );
  }

  @override
  Future<User?> googleLogin() async {
    final user = await authService.signInWithGoogle();

    if (user != null) {
      await firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': user.displayName,
        'email': user.email,
        'photoUrl': user.photoURL ?? '',
        'lastLogin': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    return user;
  }

  @override
  Future<User?> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String familyId,
  }) async {
    final user = await authService.registerWithEmail(
      email: email,
      password: password,
    );

    if (user != null) {
      await firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': name,
        'email': email,
        'phoneNumber': phone,
        'familyId': familyId,
        'photoUrl': user.photoURL ?? '',
        'lastLogin': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    return user;
  }
}