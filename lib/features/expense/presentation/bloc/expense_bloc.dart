import 'dart:async';
import 'package:expense_manager/core/constants/expense_categories.dart';
import 'package:expense_manager/features/expense/domain/usecases/add_expense.dart';
import 'package:expense_manager/features/expense/domain/usecases/load_expense.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/expense_summary.dart';
import 'expense_event.dart';
import 'expense_state.dart';

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
  }

  Future<void> _onLoadExpenses(
    LoadExpensesEvent event,
    Emitter<ExpenseState> emit,
  ) async {
    // final draft = _ExpenseDraft.fromState(state);
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

    final expensesResult = await loadExpense();

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
