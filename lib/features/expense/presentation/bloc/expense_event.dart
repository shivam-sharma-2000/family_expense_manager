import 'package:equatable/equatable.dart';
import '../../domain/entities/expense.dart';

abstract class ExpenseEvent extends Equatable {
  const ExpenseEvent();

  @override
  List<Object?> get props => [];
}

class AddExpenseEvent extends ExpenseEvent {
  final Expense expense;

  const AddExpenseEvent(this.expense);

  @override
  List<Object?> get props => [expense];
}

class UpdateExpenseEvent extends ExpenseEvent {
  final Expense expense;

  const UpdateExpenseEvent(this.expense);

  @override
  List<Object?> get props => [expense];
}

class DeleteExpenseEvent extends ExpenseEvent {
  final String expenseId;

  const DeleteExpenseEvent(this.expenseId);

  @override
  List<Object?> get props => [expenseId];
}

class LoadExpensesEvent extends ExpenseEvent {
  final DateTime? startDate;
  final DateTime? endDate;
  final String? category;

  const LoadExpensesEvent({
    this.startDate,
    this.endDate,
    this.category,
  });

  @override
  List<Object?> get props => [startDate, endDate, category];
}

class LoadExpenseSummaryEvent extends ExpenseEvent {
  final DateTime? startDate;
  final DateTime? endDate;

  const LoadExpenseSummaryEvent({
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [startDate, endDate];
}
