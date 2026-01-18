import 'package:equatable/equatable.dart';
import '../../domain/entities/expense_entity.dart';

abstract class ExpenseState extends Equatable {
  final List<ExpenseEntity> expenses;
  final double totalExpense;

  const ExpenseState({this.expenses = const [], this.totalExpense = 0.0});

  @override
  List<Object?> get props => [expenses, totalExpense];
}

class ExpenseInitial extends ExpenseState {
  const ExpenseInitial({super.expenses = const [], super.totalExpense = 0.0});
}

class ExpenseLoading extends ExpenseState {
  const ExpenseLoading({super.expenses, super.totalExpense});
}

class ExpenseError extends ExpenseState {
  final String message;

  const ExpenseError({
    required this.message,
    super.expenses,
    super.totalExpense,
  });

  @override
  List<Object?> get props => [message];
}

class ExpensesLoaded extends ExpenseState {
  const ExpensesLoaded({super.expenses, super.totalExpense});
}

class ExpenseAdded extends ExpenseState {
  final String expenseId;

  const ExpenseAdded({
    required this.expenseId,
    super.expenses,
    super.totalExpense,
  });

  @override
  List<Object?> get props => [expenseId];
}

class ExpenseSuccess extends ExpenseState {

  const ExpenseSuccess({
    super.expenses,
    super.totalExpense,
  });
}

// class ExpenseSummaryLoaded extends ExpenseState {
//   final double totalExpense;
//   final List<String> categories;
//
//   const ExpenseSummaryLoaded({
//     required this.totalExpense,
//     required this.categories,
//   });
//
//   @override
//   List<Object?> get props => [totalExpense, categories];
// }
