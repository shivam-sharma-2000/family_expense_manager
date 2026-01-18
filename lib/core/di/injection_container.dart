import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_manager/core/service/auth_service.dart';
import 'package:expense_manager/core/service/i_local_storage_service.dart';
import 'package:expense_manager/core/service/impl/auth_service_impl.dart';
import 'package:expense_manager/core/service/impl/local_storage_service.dart';
import 'package:expense_manager/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:expense_manager/features/expense/data/datasources/remote/expense_remote_data_source.dart';
import 'package:expense_manager/features/expense/data/datasources/remote/expense_remote_data_source_impl.dart';
import 'package:expense_manager/features/expense/domain/usecases/load_expense.dart';
import 'package:expense_manager/features/user/data/repositories/user_repository_impl.dart';
import 'package:expense_manager/features/user/domain/repositories/user_repository.dart';
import 'package:expense_manager/features/expense/domain/repositories/expense_repository.dart';
import 'package:expense_manager/features/expense/data/repositories/expense_repository_impl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../database/DBHelper.dart';
import '../../features/expense/data/datasources/local/database_helper.dart';
import '../../features/expense/expense_di.dart' as expense_di;
import '../../features/expense/presentation/bloc/expense_bloc.dart';

final sl = GetIt.instance;

Future<void> setupLocator() async {
  _initCoreServices();

  // Register singletons
  // Register DatabaseHelper with the correct name that matches the import
  sl.registerLazySingleton<UserRepository>(() => UserRepositoryImpl(sl(), sl()));

  // Register BLoCs
  sl.registerFactory<AuthBloc>(() => AuthBloc(sl(), sl()));

  expense_di.registerExpenseModule(sl);

}

/// Core services
void _initCoreServices() {
  sl.registerLazySingleton<ILocalStorageService>(() => LocalStorageService());
  sl.registerLazySingleton<DBHelper>(() => DBHelper.instance);
  sl.registerLazySingleton<DatabaseHelper>(() => DatabaseHelper.instance);  // Alias for DatabaseHelper
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<GoogleSignIn>(() => GoogleSignIn.instance);
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  sl.registerLazySingleton<AuthServiceImpl>(() => AuthServiceImpl(sl(), sl(), sl()));

}