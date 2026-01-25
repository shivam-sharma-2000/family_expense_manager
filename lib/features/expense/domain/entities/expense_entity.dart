import 'package:equatable/equatable.dart';

class ExpenseEntity extends Equatable {
  final String id;
  final String title;
  final double amount;
  final DateTime? date;
  final String category;
  final String? description;
  final String? receiptImagePath;
  final String? userId;
  final String? familyId;
  final bool isSynced;
  final bool isDeleted;

  const ExpenseEntity({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    this.description,
    this.receiptImagePath,
    required this.userId,
    this.familyId,
    this.isSynced = true,
    this.isDeleted = false,
  });

  // Copy with method for immutability
  ExpenseEntity copyWith({
    String? id,
    String? title,
    double? amount,
    DateTime? date,
    String? category,
    String? description,
    String? receiptImagePath,
    String? userId,
    String? familyId,
    bool? isSynced,
    bool? isDeleted,
  }) {
    return ExpenseEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      category: category ?? this.category,
      description: description ?? this.description,
      receiptImagePath: receiptImagePath ?? this.receiptImagePath,
      userId: userId ?? this.userId,
      familyId: familyId ?? this.familyId,
      isSynced: isSynced ?? this.isSynced,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        amount,
        date,
        category,
        description,
        receiptImagePath,
        userId,
        familyId,
        isSynced,
        isDeleted,
      ];
  
  // Helper method to check if expense is valid
  bool get isValid => title.isNotEmpty && category.isNotEmpty;
}
