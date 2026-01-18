import 'package:equatable/equatable.dart';
import '../../domain/entities/expense_entity.dart';

abstract class ExpenseEvent extends Equatable {
  const ExpenseEvent();

  @override
  List<Object?> get props => [];
}

class AddExpenseEvent extends ExpenseEvent {
  final ExpenseEntity expense;

  const AddExpenseEvent({required this.expense});

  @override
  List<Object?> get props => [expense];
}

class UpdateExpenseEvent extends ExpenseEvent {
  final ExpenseEntity expense;

  const UpdateExpenseEvent(this.expense);

  @override
  List<Object?> get props => [expense];
}

class DeleteExpenseEvent extends ExpenseEvent {
  final String id;

  const DeleteExpenseEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class LoadExpensesEvent extends ExpenseEvent {
  final String? userId;
  final String? familyId;

  const LoadExpensesEvent({this.userId, this.familyId});

  @override
  List<Object?> get props => [userId, familyId];
}

class SyncExpensesEvent extends ExpenseEvent {
  const SyncExpensesEvent();
}

class CheckConnectivityEvent extends ExpenseEvent {
  const CheckConnectivityEvent();
}
