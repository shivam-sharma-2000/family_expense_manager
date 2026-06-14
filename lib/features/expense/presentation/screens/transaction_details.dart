import 'package:flutter/material.dart';
import 'package:expense_manager/core/extensions/theme_extension.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:hugeicons/hugeicons.dart';

class TransactionDetails extends StatelessWidget {
  final Map<String, Object?> transaction;
  const TransactionDetails({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final amountStr = transaction['amount']?.toString() ?? '0';
    final amount = double.tryParse(amountStr) ?? 0.0;
    final isExpense = amount < 0;
    final category = transaction['category']?.toString() ?? 'Unknown';
    final method = transaction['transaction_method']?.toString() ?? 'Unknown';
    final dateStr = transaction['date']?.toString();
    final date = dateStr != null ? DateTime.tryParse(dateStr) : null;
    final dateFormatted = date != null ? DateFormat('MMM dd, yyyy HH:mm').format(date) : 'N/A';
    final receiptImagePath = transaction['receipt_image_path']?.toString();

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Transaction Details",
          style: Theme.of(context).textTheme.displaySmall,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: context.theme.colorScheme.onSurface),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Amount Header
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: context.theme.cardColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: isExpense
                          ? context.theme.colorScheme.error.withValues(alpha: 0.2)
                          : context.theme.colorScheme.secondary.withValues(alpha: 0.2),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: HugeIcon(
                  icon: isExpense ? HugeIcons.strokeRoundedArrowUp01 : HugeIcons.strokeRoundedArrowDown01,
                  size: 48,
                  color: isExpense
                      ? context.theme.colorScheme.error
                      : context.theme.colorScheme.secondary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                '${isExpense ? '-' : '+'} ₹${amount.abs().toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: isExpense
                      ? context.theme.colorScheme.error
                      : context.theme.colorScheme.secondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                category,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: context.theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 40),

              // Details Card
              Container(
                decoration: BoxDecoration(
                  color: context.theme.cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildDetailRow(context, "Date & Time", dateFormatted, HugeIcons.strokeRoundedCalendar01),
                    const Divider(height: 1, indent: 20, endIndent: 20),
                    _buildDetailRow(context, "Category", category, HugeIcons.strokeRoundedMenu01),
                    const Divider(height: 1, indent: 20, endIndent: 20),
                    _buildDetailRow(context, "Payment Method", method, HugeIcons.strokeRoundedWallet01),
                  ],
                ),
              ),

              if (receiptImagePath != null && receiptImagePath.isNotEmpty) ...[
                const SizedBox(height: 40),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Attachment",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.file(
                      File(receiptImagePath),
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        padding: const EdgeInsets.all(20),
                        color: context.theme.cardColor,
                        child: const Center(
                          child: Text("Image not found"),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String title, String value, dynamic icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: context.theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: HugeIcon(
              icon: icon,
              color: context.theme.colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
