import 'package:equatable/equatable.dart';
import '../../domain/entities/expense.dart';

class ExpenseState extends Equatable {
  final List<Expense> expenses;
  final double totalExpense;
  final String? error;
  final bool isLoading;
  final bool isSuccess;

  const ExpenseState({
    this.expenses = const [],
    this.totalExpense = 0.0,
    this.error,
    this.isLoading = false,
    this.isSuccess = false,
  });

  ExpenseState copyWith({
    List<Expense>? expenses,
    double? totalExpense,
    String? error,
    bool? isLoading,
    bool? isSuccess,
  }) {
    return ExpenseState(
      expenses: expenses ?? this.expenses,
      totalExpense: totalExpense ?? this.totalExpense,
      error: error,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }

  @override
  List<Object?> get props => [
        expenses,
        totalExpense,
        error,
        isLoading,
        isSuccess,
      ];
}

class ExpenseInitial extends ExpenseState {
  const ExpenseInitial() : super();
}

class ExpenseLoading extends ExpenseState {
  const ExpenseLoading() : super(isLoading: true);
}

class ExpenseLoaded extends ExpenseState {
  const ExpenseLoaded({
    required List<Expense> expenses,
    double totalExpense = 0.0,
  }) : super(
          expenses: expenses,
          totalExpense: totalExpense,
          isSuccess: true,
        );
}

class ExpenseError extends ExpenseState {
  const ExpenseError(String error) : super(error: error);
}

class ExpenseOperationSuccess extends ExpenseState {
  final String message;

  const ExpenseOperationSuccess({
    required this.message,
    List<Expense> expenses = const [],
    double totalExpense = 0.0,
  }) : super(
          expenses: expenses,
          totalExpense: totalExpense,
          isSuccess: true,
        );

  @override
  List<Object?> get props => [message, ...super.props];
}
