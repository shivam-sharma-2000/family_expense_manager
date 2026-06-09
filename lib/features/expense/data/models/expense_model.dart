import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/expense.dart';

class ExpenseModel extends Expense {
  const ExpenseModel({
    required super.id,
    required super.title,
    required super.amount,
    required super.date,
    required super.category,
    required super.userId,
    super.description,
    super.receiptImagePath,
    super.familyId,
    required super.paymentMethod,
  });

  // Convert a ExpenseModel into a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch,
      'category': category,
      'description': description,
      'receipt_image_path': receiptImagePath ?? '',
      'user_id' : userId,
      'family_id' : familyId ?? '',
      'payment_method' : paymentMethod,
    };
  }

  // Convert a Map into a ExpenseModel
  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      amount: double.tryParse(map['amount']?.toString() ?? '0.0') ?? 0.0,
      date: _parseDate(map['date']),
      category: map['category'] ?? '',
      description: map['description'],
      receiptImagePath: map['receipt_image_path'],
      familyId: map['family_id'],
      userId: map['user_id'],
      paymentMethod: map['payment_method'] ?? '',
    );
  }

  static DateTime? _parseDate(dynamic dateVal) {
    if (dateVal == null) return null;
    if (dateVal is Timestamp) return dateVal.toDate();
    if (dateVal is int) return DateTime.fromMillisecondsSinceEpoch(dateVal);
    if (dateVal is String) return DateTime.tryParse(dateVal);
    return null;
  }

  factory ExpenseModel.fromEntity(Expense expense) {
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
      paymentMethod: expense.paymentMethod,
    );
  }

  // Convert a Expense ExpenseModel into a entity
  Expense toEntity() {
    return Expense(
      id: id,
      title: title,
      amount: amount,
      date: date,
      category: category,
      description: description,
      receiptImagePath: receiptImagePath,
      familyId: familyId,
      userId: userId,
      paymentMethod: paymentMethod,
    );
  }
}
