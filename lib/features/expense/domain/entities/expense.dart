import 'package:equatable/equatable.dart';

class Expense extends Equatable {
  final String? id;
  final String title;
  final double amount;
  final DateTime date;
  final String category;
  final String? description;
  final String? receiptImagePath;

  const Expense({
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

  Expense copyWith({
    String? id,
    String? title,
    double? amount,
    DateTime? date,
    String? category,
    String? description,
    String? receiptImagePath,
  }) {
    return Expense(
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
