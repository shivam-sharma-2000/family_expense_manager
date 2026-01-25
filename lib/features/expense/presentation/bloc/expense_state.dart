import 'package:equatable/equatable.dart';
import 'package:expense_manager/features/expense/domain/entities/expense_summary.dart';
import '../../domain/entities/expense_entity.dart';

abstract class ExpenseState extends Equatable {
  const ExpenseState();
  @override
  List<Object?> get props => [];
}

class ExpenseInitial extends ExpenseState {
  const ExpenseInitial();
}

class ExpenseLoading extends ExpenseState {
  const ExpenseLoading();
}

class ExpenseError extends ExpenseState {
  final String message;

  const ExpenseError({
    required this.message,
  });

  @override
  List<Object?> get props => [message];
}

class ExpenseLoaded extends ExpenseState {
  final List<ExpenseEntity> expenses;
  final ExpenseSummary expenseSummary;

  const ExpenseLoaded({
    required this.expenses,
    required this.expenseSummary,
  });

  @override
  List<Object?> get props => [expenses, expenseSummary];
}

class ExpenseAdded extends ExpenseState {
  final String expenseId;

  const ExpenseAdded({
    required this.expenseId,
  });

  @override
  List<Object?> get props => [expenseId];
}

class AddExpenseSuccess extends ExpenseState {
  const AddExpenseSuccess();
}

