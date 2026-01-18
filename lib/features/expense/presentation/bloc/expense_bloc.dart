import 'dart:async';
import 'package:expense_manager/features/expense/domain/usecases/add_expense.dart';
import 'package:expense_manager/features/expense/domain/usecases/load_expense.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../user/domain/repositories/user_repository.dart';
import '../../domain/entities/expense.dart';
import '../../domain/entities/expense_entity.dart';
import '../../domain/repositories/expense_repository.dart';
import 'expense_event.dart';
import 'expense_state.dart';

class _ExpenseDraft {
  final List<ExpenseEntity> expenses;
  final double totalExpense;

  _ExpenseDraft({required this.expenses, required this.totalExpense});

  factory _ExpenseDraft.fromState(ExpenseState state) {
    return _ExpenseDraft(
      expenses: state.expenses,
      totalExpense: state.totalExpense,
    );
  }
}

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  final LoadExpense loadExpense;
  final AddExpense addExpense;

  ExpenseBloc({required this.loadExpense, required this.addExpense})
    : super(const ExpenseInitial()) {
    // Set up event handlers
    on<LoadExpensesEvent>(_onLoadExpenses);
    on<AddExpenseEvent>(_onAddExpense);
    on<UpdateExpenseEvent>(_onUpdateExpense);
    on<DeleteExpenseEvent>(_onDeleteExpense);
    on<SyncExpensesEvent>(_onSyncExpenses);
    on<CheckConnectivityEvent>(_onCheckConnectivity);

    // Initial load
    add(const LoadExpensesEvent());
  }

  Future<void> _onLoadExpenses(
    LoadExpensesEvent event,
    Emitter<ExpenseState> emit,
  ) async {
    try {
      // final draft = _ExpenseDraft.fromState(state);
      emit(const ExpenseLoading());
      final request = await loadExpense();
      request.fold((failure) => emit(ExpenseError(message: failure.title)), (
        expense,
      ) {
        var total = 0.0;
        for (final expense in expense) {
          total += expense.amount;
        }
        emit(ExpensesLoaded(expenses: expense, totalExpense: total));
        return;
      });
    } catch (e) {
      if (!isClosed) {
        emit(ExpenseError(message: 'Unexpected error: $e'));
      }
    }
  }

  Future<void> _onAddExpense(
    AddExpenseEvent event,
    Emitter<ExpenseState> emit,
  ) async {
    try {
      final draft = _ExpenseDraft.fromState(state);
      if (!event.expense.isValid) {
        emit(const ExpenseError(message: 'Please fill in all required fields'));
        return;
      }

      final res = await addExpense(event.expense);
      res.fold(
        (failure) => emit(ExpenseError(message: failure.title, expenses: draft.expenses, totalExpense: draft.totalExpense)),
        (_) {
          add(const LoadExpensesEvent());
        },
      );
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

  Future<void> _onSyncExpenses(
    SyncExpensesEvent event,
    Emitter<ExpenseState> emit,
  ) async {
    try {
      // await expenseRepository.syncWithFirebase();
      // State will be updated automatically through the stream
    } catch (e) {
      // Don't show error to user, just log it
    }
  }

  Future<void> _onCheckConnectivity(
    CheckConnectivityEvent event,
    Emitter<ExpenseState> emit,
  ) async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult != ConnectivityResult.none) {
      add(const SyncExpensesEvent());
    }
  }

  Future<double> _calculateTotal(List<Expense> expenses) async {
    return expenses.fold<double>(
      0.0,
      (double sum, expense) => sum + expense.amount,
    );
  }
}
