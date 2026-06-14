import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../features/expense/domain/entities/payment_category.dart';

const List<PaymentCategory> paymentCategories = [
  PaymentCategory(
    name: 'Cash',
    icon: HugeIcons.strokeRoundedMoney01,
    color: Color(0xFF00B894),
  ),
  PaymentCategory(
    name: 'UPI',
    icon: HugeIcons.strokeRoundedQrCode,
    color: Color(0xFF6C5CE7),
  ),
  PaymentCategory(
    name: 'Credit Card',
    icon: HugeIcons.strokeRoundedCreditCard,
    color: Color(0xFF0984E3),
  ),
  PaymentCategory(
    name: 'Debit Card',
    icon: HugeIcons.strokeRoundedCreditCard,
    color: Color(0xFF74B9FF),
  ),
  PaymentCategory(
    name: 'Bank',
    icon: HugeIcons.strokeRoundedBank,
    color: Color(0xFFFF7675),
  ),
  PaymentCategory(
    name: 'Wallet',
    icon: HugeIcons.strokeRoundedWallet01,
    color: Color(0xFFFDCB6E),
  ),
];
