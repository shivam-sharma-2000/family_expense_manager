import 'package:get_it/get_it.dart';

import 'data/datasources/local/tenant_local_data_source.dart';
import 'data/datasources/local/tenant_local_data_source_impl.dart';
import 'data/datasources/remote/tenant_remote_data_source.dart';
import 'data/datasources/remote/tenant_remote_data_source_impl.dart';
import 'data/repositories/tenant_repository_impl.dart';
import 'domain/repositories/tenant_repository.dart';
import 'domain/usecases/add_tenant.dart';
import 'domain/usecases/get_tenants.dart';
import 'domain/usecases/update_tenant.dart';
import 'domain/usecases/add_tenant_bill.dart';
import 'domain/usecases/update_tenant_bill.dart';
import 'domain/usecases/get_tenant_bills.dart';
import 'domain/usecases/add_tenant_payment.dart';
import 'domain/usecases/get_tenant_payments.dart';
import 'presentation/bloc/tenant_bloc.dart';
import 'presentation/bloc/tenant_detail_bloc.dart';

void registerTenantModule(GetIt sl) {
  // Data Sources
  sl.registerLazySingleton<TenantLocalDataSource>(
    () => TenantLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<TenantRemoteDataSource>(
    () => TenantRemoteDataSourceImpl(firestore: sl()),
  );

  // Repository
  sl.registerLazySingleton<TenantRepository>(
    () => TenantRepositoryImpl(
      localDataSource: sl(),
      remoteDataSource: sl(),
      expenseRepository: sl(),
      localStorageService: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => AddTenant(sl()));
  sl.registerLazySingleton(() => GetTenants(sl()));
  sl.registerLazySingleton(() => UpdateTenant(sl()));
  sl.registerLazySingleton(() => AddTenantBill(sl()));
  sl.registerLazySingleton(() => UpdateTenantBill(sl()));
  sl.registerLazySingleton(() => GetTenantBills(sl()));
  sl.registerLazySingleton(() => AddTenantPayment(sl()));
  sl.registerLazySingleton(() => GetTenantPayments(sl()));

  // Blocs
  sl.registerFactory(() => TenantBloc(getTenants: sl()));
  sl.registerFactory(() => TenantDetailBloc(
        getTenantBills: sl(),
        getTenantPayments: sl(),
      ));
}
