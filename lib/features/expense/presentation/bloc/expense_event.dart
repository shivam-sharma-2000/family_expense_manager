import 'package:equatable/equatable.dart';
import '../../domain/entities/expense.dart';

abstract class ExpenseEvent extends Equatable {
  const ExpenseEvent();

  @override
  List<Object?> get props => [];
}

class AddExpenseEvent extends ExpenseEvent {
  final Expense expense;

  const AddExpenseEvent({required this.expense});

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
  final String id;

  const DeleteExpenseEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class LoadExpensesEvent extends ExpenseEvent {
  final bool isFamilyMode;
  final String? targetUserId;
  final List<String>? targetUserIds;
  final String? familyId; // Deprecated or kept for compatibility

  const LoadExpensesEvent({
    this.isFamilyMode = false,
    this.targetUserId,
    this.targetUserIds,
    this.familyId,
  });

  @override
  List<Object?> get props => [isFamilyMode, targetUserId, targetUserIds, familyId];
}

class SyncExpenseEvent extends ExpenseEvent {
  const SyncExpenseEvent();
}

