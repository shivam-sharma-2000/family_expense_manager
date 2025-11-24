import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_manager/core/service/auth_service.dart';
import 'package:expense_manager/core/service/impl/auth_service_impl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../database/DBHelper.dart';
import '../../features/expense/data/repositories/expense_repository_impl.dart';
import '../../features/expense/domain/repositories/expense_repository.dart';

final sl = GetIt.instance;

Future<void> setupLocator() async {

  final prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => prefs);

  // Register singletons
  sl.registerLazySingleton<DBHelper>(() => DBHelper.instance);
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<GoogleSignIn>(() => GoogleSignIn.instance);
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  sl.registerLazySingleton<AuthService>(() => AuthServiceImpl(sl(), sl()));
  // sl.registerLazySingleton<ExpenseRepository>(() => ExpenseRepositoryImpl(databaseHelper: sl()));



}