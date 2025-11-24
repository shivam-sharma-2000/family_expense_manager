import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ExpensePage extends StatefulWidget {
  const ExpensePage({Key? key}) : super(key: key);

  @override
  _ExpensePageState createState() => _ExpensePageState();
}

class _ExpensePageState extends State<ExpensePage> {
  // Modern color scheme
  static const Color primaryColor = Color(0xFF6C63FF);
  static const Color secondaryColor = Color(0xFF4F46E5);
  static const Color successColor = Color(0xFF10B981);
  static const Color errorColor = Color(0xFFEF4444);
  static const Color backgroundColor = Color(0xFFF8FAFC);
  static const Color cardColor = Colors.white;
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);

  // Sample expense data
  final List<Map<String, dynamic>> _expenses = [
    {
      'title': 'Grocery Shopping',
      'amount': 1250.0,
      'date': DateTime.now().subtract(const Duration(days: 1)),
      'category': 'Food',
      'type': 'expense',
      'paymentMethod': 'UPI',
    },
    {
      'title': 'Freelance Work',
      'amount': 5000.0,
      'date': DateTime.now().subtract(const Duration(days: 2)),
      'category': 'Income',
      'type': 'income',
      'paymentMethod': 'Bank Transfer',
    },
    // Add more sample data as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'Expenses & Income',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: primaryColor, size: 28),
            onPressed: () {
              // TODO: Navigate to add expense/income screen
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary Card
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSummaryItem('Income', '₹12,500', successColor),
                      _buildSummaryItem('Expense', '₹8,750', errorColor),
                      _buildSummaryItem('Balance', '₹3,750', primaryColor),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Show add expense/income dialog
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Add Transaction',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Recent Transactions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Transactions',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // TODO: Navigate to all transactions
                  },
                  child: Text(
                    'See All',
                    style: GoogleFonts.poppins(
                      color: primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Transaction List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: _expenses.length,
              itemBuilder: (context, index) {
                final expense = _expenses[index];
                final isIncome = expense['type'] == 'income';
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 1,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: isIncome 
                            ? successColor.withOpacity(0.1) 
                            : errorColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                        color: isIncome ? successColor : errorColor,
                        size: 24,
                      ),
                    ),
                    title: Text(
                      expense['title'],
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      '${expense['category']} • ${expense['paymentMethod']}\n${DateFormat('MMM dd, yyyy').format(expense['date'])}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: textSecondary,
                      ),
                    ),
                    trailing: Text(
                      '${isIncome ? '+' : '-'} ₹${expense['amount'].toStringAsFixed(2)}',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isIncome ? successColor : errorColor,
                      ),
                    ),
                    onTap: () {
                      // TODO: Show transaction details
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String title, String amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          amount,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
