import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../features/expense/domain/entities/expense_category_entity.dart';

class ExpenseCategories {
  static const spend = [
    ExpenseCategory(
      name: 'Food',
      icon: HugeIcons.strokeRoundedRestaurant01,
      color: Color(0xFFFF6B6B),
    ),
    ExpenseCategory(
      name: 'Transport',
      icon: HugeIcons.strokeRoundedCar01,
      color: Color(0xFF4D96FF),
    ),
    ExpenseCategory(
      name: 'Shopping',
      icon: HugeIcons.strokeRoundedShoppingBag01,
      color: Color(0xFF6C5CE7),
    ),
    ExpenseCategory(
      name: 'Bills',
      icon: HugeIcons.strokeRoundedInvoice01,
      color: Color(0xFF00B894),
    ),
    ExpenseCategory(
      name: 'Entertainment',
      icon: HugeIcons.strokeRoundedTicket01,
      color: Color(0xFFFD79A8),
    ),
    ExpenseCategory(
      name: 'Health',
      icon: HugeIcons.strokeRoundedHeartAdd,
      color: Color(0xFF00CEC9),
    ),
    ExpenseCategory(
      name: 'Education',
      icon: HugeIcons.strokeRoundedBookOpen01,
      color: Color(0xFF6C5CE7),
    ),
    ExpenseCategory(
      name: 'Other',
      icon: HugeIcons.strokeRoundedMoreHorizontalCircle01,
      color: Color(0xFFA4B0BE),
    ),
  ];

  static const income = [
    ExpenseCategory(
      name: 'Salary',
      icon: HugeIcons.strokeRoundedInvoice01,
      color: Color(0xFF00B894),
    ),
    ExpenseCategory(
      name: 'Rent',
      icon: HugeIcons.strokeRoundedHome01,
      color: Color(0xFFFF6B6B),
    ),
    ExpenseCategory(
      name: 'Gift',
      icon: HugeIcons.strokeRoundedGift,
      color: Color(0xFF4D96FF),
    ),
    ExpenseCategory(
      name: 'Cashback',
      icon: HugeIcons.strokeRoundedCash01,
      color: Color(0xFF6C5CE7),
    ),
    ExpenseCategory(
      name: 'Other',
      icon: HugeIcons.strokeRoundedMoreHorizontalCircle01,
      color: Color(0xFFA4B0BE),
    ),
  ];
}
