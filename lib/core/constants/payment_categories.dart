import 'package:flutter/material.dart';

import '../../features/expense/domain/entities/payment_category.dart';

const List<PaymentCategory> paymentCategories = [
  PaymentCategory(
    name: 'Cash',
    icon: Icons.currency_rupee,
    color: Color(0xFF00B894),
  ),
  PaymentCategory(
    name: 'UPI',
    icon: Icons.qr_code,
    color: Color(0xFF6C5CE7),
  ),
  PaymentCategory(
    name: 'Credit Card',
    icon: Icons.credit_card,
    color: Color(0xFF0984E3),
  ),
  PaymentCategory(
    name: 'Debit Card',
    icon: Icons.credit_card_outlined,
    color: Color(0xFF74B9FF),
  ),
  PaymentCategory(
    name: 'Bank',
    icon: Icons.account_balance,
    color: Color(0xFFFF7675),
  ),
  PaymentCategory(
    name: 'Wallet',
    icon: Icons.account_balance_wallet,
    color: Color(0xFFFDCB6E),
  ),
];
