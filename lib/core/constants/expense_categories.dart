import 'package:flutter/material.dart';

import '../../features/expense/domain/entities/expense_category_entity.dart';

class ExpenseCategories {
  static const spend = [
    ExpenseCategory(
      name: 'Food',
      icon: Icons.restaurant,
      color: Color(0xFFFF6B6B),
    ),
    ExpenseCategory(
      name: 'Transport',
      icon: Icons.directions_car,
      color: Color(0xFF4D96FF),
    ),
    ExpenseCategory(
      name: 'Shopping',
      icon: Icons.shopping_bag,
      color: Color(0xFF6C5CE7),
    ),
    ExpenseCategory(
      name: 'Bills',
      icon: Icons.receipt,
      color: Color(0xFF00B894),
    ),
    ExpenseCategory(
      name: 'Entertainment',
      icon: Icons.movie,
      color: Color(0xFFFD79A8),
    ),
    ExpenseCategory(
      name: 'Health',
      icon: Icons.health_and_safety,
      color: Color(0xFF00CEC9),
    ),
    ExpenseCategory(
      name: 'Education',
      icon: Icons.school,
      color: Color(0xFF6C5CE7),
    ),
    ExpenseCategory(
      name: 'Other',
      icon: Icons.more_horiz,
      color: Color(0xFFA4B0BE),
    ),
  ];

  static const income = [
    ExpenseCategory(
      name: 'Salary',
      icon: Icons.receipt,
      color: Color(0xFF00B894),
    ),
    ExpenseCategory(
      name: 'Rent',
      icon: Icons.house,
      color: Color(0xFFFF6B6B),
    ),
    ExpenseCategory(
      name: 'Gift',
      icon: Icons.card_giftcard,
      color: Color(0xFF4D96FF),
    ),
    ExpenseCategory(
      name: 'Cashback',
      icon: Icons.payments_outlined,
      color: Color(0xFF6C5CE7),
    ),
    ExpenseCategory(
      name: 'Other',
      icon: Icons.more_horiz,
      color: Color(0xFFA4B0BE),
    ),
  ];
}
