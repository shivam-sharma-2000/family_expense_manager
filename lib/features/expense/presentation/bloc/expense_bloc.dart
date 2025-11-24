import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/expense.dart';
import '../../domain/repositories/expense_repository.dart';
import 'expense_event.dart';
import 'expense_state.dart';

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  final ExpenseRepository expenseRepository;

  ExpenseBloc({required this.expenseRepository}) : super(ExpenseInitial()) {
    on<AddExpenseEvent>(_onAddExpense);
    on<UpdateExpenseEvent>(_onUpdateExpense);
    on<DeleteExpenseEvent>(_onDeleteExpense);
    on<LoadExpensesEvent>(_onLoadExpenses);
    on<LoadExpenseSummaryEvent>(_onLoadExpenseSummary);
  }

  Future<void> _onAddExpense(
    AddExpenseEvent event,
    Emitter<ExpenseState> emit,
  ) async {
    try {
      emit(ExpenseLoading());
      await expenseRepository.addExpense(event.expense);
      final expenses = await expenseRepository.getAllExpenses();
      final total = await expenseRepository.getTotalExpense();
      
      emit(ExpenseOperationSuccess(
        message: 'Expense added successfully',
        expenses: expenses,
        totalExpense: total,
      ));
    } catch (e) {
      emit(ExpenseError('Failed to add expense: $e'));
    }
  }

  Future<void> _onUpdateExpense(
    UpdateExpenseEvent event,
    Emitter<ExpenseState> emit,
  ) async {
    try {
      emit(ExpenseLoading());
      await expenseRepository.updateExpense(event.expense);
      final expenses = await expenseRepository.getAllExpenses();
      final total = await expenseRepository.getTotalExpense();
      
      emit(ExpenseOperationSuccess(
        message: 'Expense updated successfully',
        expenses: expenses,
        totalExpense: total,
      ));
    } catch (e) {
      emit(ExpenseError('Failed to update expense: $e'));
    }
  }

  Future<void> _onDeleteExpense(
    DeleteExpenseEvent event,
    Emitter<ExpenseState> emit,
  ) async {
    try {
      emit(ExpenseLoading());
      await expenseRepository.deleteExpense(event.expenseId);
      final expenses = await expenseRepository.getAllExpenses();
      final total = await expenseRepository.getTotalExpense();
      
      emit(ExpenseOperationSuccess(
        message: 'Expense deleted successfully',
        expenses: expenses,
        totalExpense: total,
      ));
    } catch (e) {
      emit(ExpenseError('Failed to delete expense: $e'));
    }
  }

  Future<void> _onLoadExpenses(
    LoadExpensesEvent event,
    Emitter<ExpenseState> emit,
  ) async {
    try {
      emit(ExpenseLoading());
      List<Expense> expenses;
      
      if (event.startDate != null && event.endDate != null) {
        expenses = await expenseRepository.getExpensesByDateRange(
          event.startDate!,
          event.endDate!,
        );
      } else if (event.category != null) {
        expenses = await expenseRepository.getExpensesByCategory(event.category!);
      } else {
        expenses = await expenseRepository.getAllExpenses();
      }
      
      final total = await _calculateTotal(expenses);
      
      emit(ExpenseLoaded(
        expenses: expenses,
        totalExpense: total,
      ));
    } catch (e) {
      emit(ExpenseError('Failed to load expenses: $e'));
    }
  }

  Future<void> _onLoadExpenseSummary(
    LoadExpenseSummaryEvent event,
    Emitter<ExpenseState> emit,
  ) async {
    try {
      emit(ExpenseLoading());
      final total = await expenseRepository.getTotalExpense(
        start: event.startDate,
        end: event.endDate,
      );
      
      emit(state.copyWith(totalExpense: total));
    } catch (e) {
      emit(ExpenseError('Failed to load expense summary: $e'));
    }
  }

  Future<double> _calculateTotal(List<Expense> expenses) async {
    return expenses.fold<double>(
      0.0,
      (double sum, expense) => sum + expense.amount,
    );
  }
}
