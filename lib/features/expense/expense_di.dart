import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_manager/features/expense/data/datasources/local/database_helper.dart';
import 'package:expense_manager/features/expense/data/datasources/remote/expense_remote_data_source.dart';
import 'package:expense_manager/features/expense/data/repositories/expense_repository_impl.dart';
import 'package:expense_manager/features/expense/domain/repositories/expense_repository.dart';
import 'package:expense_manager/features/expense/domain/usecases/add_expense.dart';
import 'package:expense_manager/features/expense/domain/usecases/load_expense.dart';
import 'package:expense_manager/features/expense/presentation/bloc/expense_bloc.dart';
import 'package:get_it/get_it.dart';
import 'data/datasources/remote/expense_remote_data_source_impl.dart';

/// Registers all Auth-related dependencies.
/// Call this from your central DI initializer.
void registerExpenseModule(GetIt sl) {
  // Data layer
  sl.registerLazySingleton<ExpenseRemoteDataSource>(
    () =>
        ExpenseRemoteDataSourceImpl(firebaseFirestore: sl<FirebaseFirestore>()),
  );
  sl.registerLazySingleton<ExpenseRepository>(
    () => ExpenseRepositoryImpl(
      databaseHelper: sl<DatabaseHelper>(),
      remote: sl<ExpenseRemoteDataSource>(),
    ),
  );

  // Domain layer
  sl.registerLazySingleton<LoadExpense>(
    () => LoadExpense(repository: sl<ExpenseRepository>()),
  );
  sl.registerLazySingleton<AddExpense>(
    () => AddExpense(repository: sl<ExpenseRepository>()),
  );

  // Presentation layer
  sl.registerLazySingleton<ExpenseBloc>(
    () => ExpenseBloc(
      loadExpense: sl<LoadExpense>(),
      addExpense: sl<AddExpense>(),
    ),
  );
}
