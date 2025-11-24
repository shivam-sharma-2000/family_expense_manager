import 'package:equatable/equatable.dart';

class ExpenseEntity extends Equatable {
  final String? id;
  final String title;
  final double amount;
  final DateTime date;
  final String category;
  final String? description;
  final String? receiptImagePath;

  const ExpenseEntity({
    this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    this.description,
    this.receiptImagePath,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        amount,
        date,
        category,
        description,
        receiptImagePath,
      ];

  ExpenseEntity copyWith({
    String? id,
    String? title,
    double? amount,
    DateTime? date,
    String? category,
    String? description,
    String? receiptImagePath,
  }) {
    return ExpenseEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      category: category ?? this.category,
      description: description ?? this.description,
      receiptImagePath: receiptImagePath ?? this.receiptImagePath,
    );
  }
}
