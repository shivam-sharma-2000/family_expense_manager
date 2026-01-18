import '../../domain/entities/expense_entity.dart';

class ExpenseModel extends ExpenseEntity {
  const ExpenseModel({
    required String id,
    required String title,
    required double amount,
    required DateTime? date,
    required String category,
    required String? userId,
    String? description,
    String? receiptImagePath,
    String? familyId,
  }) : super(
          id: id,
          title: title,
          amount: amount,
          date: date,
          category: category,
          description: description,
          receiptImagePath: receiptImagePath,
    familyId: familyId,
    userId: userId,
        );

  // Convert a ExpenseModel into a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date?.millisecondsSinceEpoch,
      'category': category,
      'description': description,
      'receipt_image_path': receiptImagePath ?? '',
      'user_id' : userId,
      'family_id' : familyId ?? '',
    };
  }

  // Convert a Map into a ExpenseModel
  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      amount: double.tryParse(map['amount']?.toString() ?? '0.0') ?? 0.0,
      date: map['date'] != null ? DateTime.fromMillisecondsSinceEpoch(map['date']) : null,
      category: map['category'] ?? '',
      description: map['description'],
      receiptImagePath: map['receipt_image_path'],
      familyId: map['family_id'],
      userId: map['user_id'],
    );
  }


  factory ExpenseModel.fromEntity(ExpenseEntity expense) {
    return ExpenseModel(
      id: expense.id,
      title: expense.title,
      amount: expense.amount,
      date: expense.date,
      category: expense.category,
      description: expense.description,
      receiptImagePath: expense.receiptImagePath,
      familyId: expense.familyId,
      userId: expense.userId,
    );
  }

  // Convert a Expense ExpenseModel into a entity
  ExpenseEntity toEntity() {
    return ExpenseEntity(
      id: id,
      title: title,
      amount: amount,
      date: date,
      category: category,
      description: description,
      receiptImagePath: receiptImagePath,
      familyId: familyId,
      userId: userId,
    );
  }
}
