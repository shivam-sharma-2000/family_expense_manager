import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_manager/core/service/database_helper.dart';
import 'package:expense_manager/core/service/i_local_storage_service.dart';
import 'package:expense_manager/core/service/impl/auth_service_impl.dart';
import 'package:expense_manager/core/service/impl/local_storage_service.dart';
import 'package:expense_manager/features/auth/data/repositories/auth_repositories_impl.dart';
import 'package:expense_manager/features/auth/domain/repositories/auth_repositories.dart';
import 'package:expense_manager/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:expense_manager/features/user/data/repositories/user_repository_impl.dart';
import 'package:expense_manager/features/user/domain/repositories/user_repository.dart';
import 'package:expense_manager/features/user/presentation/bloc/user_bloc.dart';
import 'package:expense_manager/features/family/data/repositories/family_repository_impl.dart';
import 'package:expense_manager/features/family/domain/repositories/family_repository.dart';
import 'package:expense_manager/features/family/presentation/bloc/family_bloc.dart';
import 'package:expense_manager/features/home/presentation/bloc/home_bloc.dart';
import 'package:expense_manager/features/sync/presentation/bloc/sync_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../features/tenant/tenant_di.dart' as tenant_di;
import '../theme/bloc/theme_bloc.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  _initCoreServices();

  // Register singletons
  sl.registerLazySingleton<DatabaseHelper>(() => DatabaseHelper.instance);
  // Register DatabaseHelper with the correct name that matches the import
  sl.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(sl(), sl()),
  );
  sl.registerLazySingleton<FamilyRepository>(() => FamilyRepositoryImpl(sl()));
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(authService: sl(), firestore: sl()),
  );

  // Register BLoCs
  sl.registerFactory<AuthBloc>(() => AuthBloc(sl()));
  sl.registerFactory<ThemeBloc>(() => ThemeBloc(sl()));
  sl.registerFactory<UserBloc>(() => UserBloc(userRepository: sl()));
  sl.registerFactory<FamilyBloc>(
    () => FamilyBloc(familyRepository: sl(), userRepository: sl()),
  );
  sl.registerFactory<HomeBloc>(() => HomeBloc(repository: sl()));
  sl.registerFactory<SyncBloc>(
    () => SyncBloc(repository: sl(), localStorageService: sl()),
  );
  tenant_di.registerTenantModule(sl);
}

/// Core services
void _initCoreServices() {
  sl.registerLazySingleton<ILocalStorageService>(() => LocalStorageService());
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<GoogleSignIn>(() => GoogleSignIn.instance);
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  sl.registerLazySingleton<AuthServiceImpl>(
    () => AuthServiceImpl(sl(), sl(), sl()),
  );
}
