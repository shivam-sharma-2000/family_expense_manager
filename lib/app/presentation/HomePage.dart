import 'package:expense_manager/app/routes/my_app_router_const.dart';
import 'package:expense_manager/features/expense/domain/entities/expense_entity.dart';
import 'package:expense_manager/features/expense/presentation/widgets/bar_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import '../../database/DBHelper.dart';
import '../../features/auth/presentation/LoginPage.dart';
import '../../features/expense/presentation/bloc/expense_bloc.dart';
import '../../features/expense/presentation/bloc/expense_event.dart';
import '../../features/expense/presentation/bloc/expense_state.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double cBalance = 0;
  double dBalance = 0;
  late final auth;

  DBHelper dbHelper = DBHelper.instance;
  late Database db;
  String sumOfOnlineExpense = "0.00";
  String sumOfCashExpense = "0.00";

  String sumOfOnlineIncome = "0.00";
  String sumOfCashIncome = "0.00";

  late List<ExpenseEntity> listOfRecentTransaction = [];

  // Modern color scheme
  static const Color primaryColor = Color(0xFF6C63FF);
  static const Color successColor = Color(0xFF10B981);
  static const Color errorColor = Color(0xFFEF4444);
  static const Color backgroundColor = Color(0xFFF8FAFC);
  static const Color cardColor = Colors.white;
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);

  // Modern text styles
  final TextStyle heading1 = GoogleFonts.poppins(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    letterSpacing: -0.5,
  );

  final TextStyle heading2 = GoogleFonts.poppins(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    letterSpacing: -0.3,
  );

  final TextStyle heading3 = GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  final TextStyle bodyLarge = GoogleFonts.poppins(
    fontSize: 16,
    color: textPrimary,
    height: 1.5,
  );

  final TextStyle bodyMedium = GoogleFonts.poppins(
    fontSize: 14,
    color: textSecondary,
    height: 1.5,
  );

  final TextStyle bodySmall = GoogleFonts.poppins(
    fontSize: 12,
    color: textSecondary,
    height: 1.5,
  );

  final TextStyle buttonText = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: 0.5,
  );

  @override
  void dispose() {
    // _expensesSubscription?.cancel();
    // _connectivitySubscription?.cancel();
    super.dispose();
  }

  late final expenseBloc = context.read<ExpenseBloc>();

  @override
  void initState() {
    super.initState();
    expenseBloc.add(const LoadExpensesEvent());
  }

  Future<void> initializeDB() async {
    db = await dbHelper.database;
  }

  void _navigateToAddExpense(String cas) {
    context.push("${MyAppRouteConst.add_expense}/$cas");
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ExpenseBloc, ExpenseState>(
      listener: (context, state) {
        if (state is ExpenseError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
        if (state is ExpenseLoaded) {
          setState(() {
            dBalance = state.expenseSummary.totalExpense;
            cBalance = state.expenseSummary.totalIncome;
          });
        }
        if (state is AddExpenseSuccess) {
          expenseBloc.add(const LoadExpensesEvent());
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: RefreshIndicator(
            onRefresh: () async {
              expenseBloc.add(const LoadExpensesEvent());
              return Future.delayed(const Duration(seconds: 1));
            },
            backgroundColor: backgroundColor,
            child: SafeArea(
              child: CustomScrollView(
                slivers: [
                  // Header Section
                  SliverAppBar(
                    backgroundColor: backgroundColor,
                    elevation: 0,
                    floating: true,
                    pinned: false,
                    title: Text(
                      'Dashboard',
                      style: heading1.copyWith(fontSize: 24),
                    ),
                    leading: IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.menu,
                          color: textPrimary,
                          size: 22,
                        ),
                      ),
                      onPressed: () {},
                    ),
                    actions: [
                      IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.5),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.notifications_outlined,
                            color: textPrimary,
                            size: 24,
                          ),
                        ),
                        onPressed: () {},
                      ),
                    ],
                  ),

                  // Profile Card
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Welcome back', style: bodySmall),
                                const SizedBox(height: 4),
                                Text('Shivam Sharma', style: heading2),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.more_vert_rounded,
                              color: Colors.grey,
                            ),
                            onPressed: () => showActionView(context),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Income and Expense Summary
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildSummaryCard(
                            'Monthly Income',
                            cBalance,
                            successColor,
                            Icons.arrow_downward,
                          ),
                          _buildSummaryCard(
                            'Monthly Expense',
                            dBalance,
                            errorColor,
                            Icons.arrow_upward,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Recent Transactions Section
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (state is ExpenseLoading) ...[
                            const Center(child: CircularProgressIndicator()),
                            const SizedBox(height: 20),
                          ] else if (state is ExpenseLoaded) ...[
                            // Expense Summary
                            if (state
                                .expenseSummary
                                .expenseByCategory
                                .isNotEmpty)
                              Container(
                                padding: const EdgeInsets.only(top: 15),
                                decoration: BoxDecoration(
                                  color: cardColor,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.5),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Text('Top Five Expenses', style: heading3),
                                    const SizedBox(height: 16),
                                    ExpenseBarChart(
                                      categoryCase: 'expense',
                                      categoryTotals: state
                                          .expenseSummary
                                          .expenseByCategory,
                                    ),
                                  ],
                                ),
                              ),

                            const SizedBox(height: 16),

                            if (state
                                .expenseSummary
                                .incomeByCategory
                                .isNotEmpty)
                              Container(
                                padding: const EdgeInsets.only(top: 15),
                                decoration: BoxDecoration(
                                  color: cardColor,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.5),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Text('Top Five Incomes', style: heading3),
                                    const SizedBox(height: 16),
                                    ExpenseBarChart(
                                      categoryCase: 'income',
                                      categoryTotals:
                                          state.expenseSummary.incomeByCategory,
                                    ),
                                  ],
                                ),
                              ),

                            const SizedBox(height: 16),

                            // Recent Transactions
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Recent Transactions', style: heading3),
                                TextButton(
                                  onPressed: () {
                                    // Navigate to all transactions screen
                                  },
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: const Text(
                                    'See All',
                                    style: TextStyle(
                                      color: primaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),
                            if (state.expenses.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 32.0),
                                child: Center(
                                  child: Text('No transactions yet'),
                                ),
                              )
                            else
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: state.expenses.take(5).length,
                                itemBuilder: (context, index) {
                                  final expense = state.expenses[index];
                                  final isExpense = expense.amount < 0;

                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 2,
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: isExpense
                                            ? errorColor.withValues(alpha: 0.2)
                                            : successColor.withValues(alpha: 0.2),
                                        child: Icon(
                                          isExpense
                                              ? Icons.arrow_upward
                                              : Icons.arrow_downward,
                                          color: isExpense
                                              ? errorColor
                                              : successColor,
                                        ),
                                      ),
                                      title: Text(
                                        expense.category,
                                        style: heading3.copyWith(fontSize: 16),
                                      ),
                                      subtitle: (expense.date != null)
                                          ? Text(
                                              DateFormat(
                                                'MMM dd, yyyy',
                                              ).format(expense.date!),
                                              style: bodySmall,
                                            )
                                          : const SizedBox.shrink(),
                                      trailing: Text(
                                        '${isExpense ? '-' : '+'} \$${expense.amount.abs().toStringAsFixed(2)}',
                                        style: GoogleFonts.poppins(
                                          color: isExpense
                                              ? errorColor
                                              : successColor,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                        ),
                                      ),
                                      onTap: () {
                                        // Navigate to expense detail
                                      },
                                    ),
                                  );
                                },
                              ),
                          ],
                          if (state is ExpenseError) ...[
                            Center(
                              child: Column(
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    color: errorColor,
                                    size: 48,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Failed to load expenses',
                                    style: heading3.copyWith(color: errorColor),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    state.message,
                                    style: bodyMedium,
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: () => expenseBloc.add(
                                      const LoadExpensesEvent(),
                                    ),
                                    child: const Text('Retry'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // Action Buttons
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                _navigateToAddExpense('spend');
                              },
                              icon: const Icon(
                                Icons.arrow_upward,
                                color: Colors.white,
                              ),
                              label: Text('Spend', style: buttonText),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: errorColor,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                _navigateToAddExpense('receive');
                              },
                              icon: const Icon(
                                Icons.arrow_downward,
                                color: Colors.white,
                              ),
                              label: Text('Receive', style: buttonText),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: successColor,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard(
    String title,
    double amount,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 36, color: color),
          const SizedBox(height: 12),
          Text(title, style: bodyMedium),
          const SizedBox(height: 8),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: heading2.copyWith(color: color),
          ),
        ],
      ),
    );
  }

  showActionView(context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const SizedBox(height: 10),
                Text(
                  "Action View",
                  style: GoogleFonts.poppins(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 10),
                Material(
                  borderRadius: const BorderRadius.all(Radius.circular(5)),
                  elevation: 5,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: const BorderRadius.all(Radius.circular(5)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 15.0,
                        bottom: 15,
                        left: 10,
                        right: 10,
                      ),
                      child: Text(
                        'View Day Wise Expense',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Material(
                  borderRadius: const BorderRadius.all(Radius.circular(5)),
                  elevation: 5,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: const BorderRadius.all(Radius.circular(5)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 15.0,
                        bottom: 15,
                        left: 10,
                        right: 10,
                      ),
                      child: Text(
                        'View Month Wise Expense',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Material(
                  borderRadius: const BorderRadius.all(Radius.circular(5)),
                  elevation: 5,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: const BorderRadius.all(Radius.circular(5)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 15.0,
                        bottom: 15,
                        left: 10,
                        right: 10,
                      ),
                      child: Text(
                        'Analyse Expense',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Material(
                  borderRadius: const BorderRadius.all(Radius.circular(5)),
                  elevation: 5,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: const BorderRadius.all(Radius.circular(5)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 15.0,
                        bottom: 15,
                        left: 10,
                        right: 10,
                      ),
                      child: Text(
                        'Setting',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                GestureDetector(
                  onTap: () {
                    auth.signOut();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                      (Route<dynamic> route) => false,
                    );
                  },
                  child: Material(
                    borderRadius: const BorderRadius.all(Radius.circular(5)),
                    elevation: 5,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(5),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 15.0,
                          bottom: 15,
                          left: 10,
                          right: 10,
                        ),
                        child: Text(
                          'Logout',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                // Add more ListTiles for other actions
              ],
            ),
          ),
        );
      },
    );
  }

  void getDailyExpense() async {
    double total = await dbHelper.retrieveTodayExpense(db, "online");
    if (total != 0) {
      setState(() {
        sumOfOnlineExpense = total.toString();
      });
    }
    total = await dbHelper.retrieveTodayExpense(db, "cash");
    if (total != 0) {
      setState(() {
        sumOfCashExpense = total.toString();
      });
    }
  }

  void getIncomes() async {
    double total = await dbHelper.retrieveTotalIncome(db, "online");
    if (total != 0) {
      setState(() {
        sumOfOnlineIncome = total.toString();
      });
    }
    total = await dbHelper.retrieveTodayExpense(db, "cash");
    if (total != 0) {
      setState(() {
        sumOfCashIncome = total.toString();
      });
    }
  }

  void getTodayIncomes() async {
    double total = await dbHelper.retrieveTodayIncome(db, "online");
    if (total != 0) {
      setState(() {
        sumOfOnlineIncome = total.toString();
      });
    }
    total = await dbHelper.retrieveTodayIncome(db, "cash");
    if (total != 0) {
      setState(() {
        sumOfCashIncome = total.toString();
      });
    }
  }
}
