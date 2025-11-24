import '../../domain/entities/expense.dart';

class ExpenseModel extends Expense {
  const ExpenseModel({
    String? id,
    required String title,
    required double amount,
    required DateTime date,
    required String category,
    String? description,
    String? receiptImagePath,
  }) : super(
          id: id,
          title: title,
          amount: amount,
          date: date,
          category: category,
          description: description,
          receiptImagePath: receiptImagePath,
        );

  // Convert a ExpenseModel into a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.millisecondsSinceEpoch,
      'category': category,
      'description': description,
      'receipt_image_path': receiptImagePath,
    };
  }

  // Convert a Map into a ExpenseModel
  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      id: map['id'],
      title: map['title'],
      amount: map['amount'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      category: map['category'],
      description: map['description'],
      receiptImagePath: map['receipt_image_path'],
    );
  }

  // Convert a Expense entity into a ExpenseModel
  factory ExpenseModel.fromEntity(Expense expense) {
    return ExpenseModel(
      id: expense.id,
      title: expense.title,
      amount: expense.amount,
      date: expense.date,
      category: expense.category,
      description: expense.description,
      receiptImagePath: expense.receiptImagePath,
    );
  }
}
