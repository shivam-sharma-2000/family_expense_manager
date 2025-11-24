import 'package:expense_manager/core/service/auth_service.dart';
import 'package:expense_manager/core/service/impl/auth_service_impl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../service/user_service.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Firebase Auth
  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  
  // Services
  getIt.registerLazySingleton<AuthService>(
    () => AuthServiceImpl(getIt<FirebaseAuth>(), getIt<GoogleSignIn>()),
  );
  
  getIt.registerLazySingleton<UserService>(() => UserService());
}
