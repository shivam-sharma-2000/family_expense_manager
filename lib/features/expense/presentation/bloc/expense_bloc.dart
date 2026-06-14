import 'dart:async';
import 'package:expense_manager/core/constants/expense_categories.dart';
import 'package:expense_manager/features/expense/domain/usecases/add_expense.dart';
import 'package:expense_manager/features/expense/domain/usecases/load_expense.dart';
import 'package:expense_manager/features/expense/domain/usecases/sync_expense.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart' as fpdart;
import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure/failure.dart';
import '../../domain/entities/expense.dart';
import '../../domain/entities/expense_summary.dart';
import 'expense_event.dart';
import 'expense_state.dart';

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  final LoadExpense loadExpense;
  final AddExpense addExpense;
  final SyncExpense syncExpense;

  ExpenseBloc({required this.loadExpense, required this.addExpense, required this.syncExpense})
    : super(const ExpenseInitial()) {
    // Set up event handlers
    on<LoadExpensesEvent>(_onLoadExpenses);
    on<AddExpenseEvent>(_onAddExpense);
    on<UpdateExpenseEvent>(_onUpdateExpense);
    on<DeleteExpenseEvent>(_onDeleteExpense);
    on<SyncExpenseEvent>(_onSyncExpense);
  }

  Future<void> _onSyncExpense(
    SyncExpenseEvent event,
    Emitter<ExpenseState> emit,
  ) async {
    // Fire and forget to prevent blocking other events like LoadExpensesEvent
    syncExpense().catchError((e) {
      // Ignore background sync errors
      return const fpdart.Left(NetworkFailure());
    });
  }

  Future<void> _onLoadExpenses(
    LoadExpensesEvent event,
    Emitter<ExpenseState> emit,
  ) async {
    emit(const ExpenseLoading());
    double totalExpense = 0;
    double totalIncome = 0;
    final Map<String, double> expCategoryTotals;
    final Map<String, double> incomeCategoryTotals;
    expCategoryTotals = ExpenseCategories.spend.asMap().map(
      (key, value) => MapEntry(value.name, 0.0),
    );
    incomeCategoryTotals = ExpenseCategories.income.asMap().map(
      (key, value) => MapEntry(value.name, 0.0),
    );

    // Determine how to fetch based on mode
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

    final Either<Failure, List<Expense>> expensesResult;

    if (event.isFamilyMode) {
      if (event.targetUserId != null) {
        // Family mode, but filtered to a specific user
        expensesResult = await loadExpense(
          userId: event.targetUserId,
        );
      } else if (event.targetUserIds != null && event.targetUserIds!.isNotEmpty) {
        // Family mode, all users using whereIn
        expensesResult = await loadExpense(userIds: event.targetUserIds);
      } else if (event.familyId != null && event.familyId!.isNotEmpty) {
        // Fallback if targetUserIds not provided
        expensesResult = await loadExpense(familyId: event.familyId);
      } else {
        expensesResult = await loadExpense(userId: currentUserId);
      }
    } else {
      // Individual mode
      expensesResult = await loadExpense(userId: currentUserId);
    }

    expensesResult.fold(
      (failure) => emit(ExpenseError(message: failure.title)),
      (expenses) {
        for (final expense in expenses) {
          if (expense.amount < 0) {
            totalExpense += expense.amount.abs();
            expCategoryTotals.update(
              expense.category,
              (value) => value + expense.amount.abs(),
              ifAbsent: () => expense.amount.abs(),
            );
          } else {
            totalIncome += expense.amount;
            incomeCategoryTotals.update(
              expense.category,
              (value) => value + expense.amount.abs(),
              ifAbsent: () => expense.amount.abs(),
            );
          }
        }
        emit(
          ExpenseLoaded(
            expenses: expenses,
            expenseSummary: ExpenseSummary(
              totalExpense: totalExpense,
              totalIncome: totalIncome,
              expenseByCategory: expCategoryTotals,
              incomeByCategory: incomeCategoryTotals,
            ),
          ),
        );
      },
    );
  }

  Future<void> _onAddExpense(
    AddExpenseEvent event,
    Emitter<ExpenseState> emit,
  ) async {
    try {
      if (!event.expense.isValid) {
        emit(const ExpenseError(message: 'Please fill in all required fields'));
        return;
      }

      emit(const ExpenseLoading());

      final res = await addExpense(event.expense);
      res.fold((failure) => emit(ExpenseError(message: failure.title)), (_) {
        emit(const AddExpenseSuccess());
      });
    } catch (e) {
      emit(ExpenseError(message: 'Failed to add expense: $e'));
      rethrow;
    }
  }

  Future<void> _onUpdateExpense(
    UpdateExpenseEvent event,
    Emitter<ExpenseState> emit,
  ) async {
    try {
      if (!event.expense.isValid) {
        emit(const ExpenseError(message: 'Please fill in all required fields'));
        return;
      }

      // await expenseRepository.updateExpense(event.expense);
      // State will be updated automatically through the stream
    } catch (e) {
      emit(ExpenseError(message: 'Failed to update expense: $e'));
      rethrow;
    }
  }

  Future<void> _onDeleteExpense(
    DeleteExpenseEvent event,
    Emitter<ExpenseState> emit,
  ) async {
    try {
      // await expenseRepository.deleteExpense(event.id);
      // State will be updated automatically through the stream
    } catch (e) {
      emit(ExpenseError(message: 'Failed to delete expense: $e'));
      rethrow;
    }
  }
}
