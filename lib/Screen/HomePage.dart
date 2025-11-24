import 'package:expense_manager/Screen/LoginPage.dart';
import 'package:expense_manager/Screen/TransactionDetails.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icons.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:sqflite/sqflite.dart';
import '../core/di/injection_container.dart';
import '../core/service/auth_service.dart';
import 'AddExpensePage.dart';
// import 'package:syncfusion_flutter_charts/charts.dart';

import '../database/DBHelper.dart';
import 'AddExpensPage.dart';

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

  late List<Map<String, Object?>> listOfPassBookEntry = [];

  // Modern color scheme
  static const Color primaryColor = Color(0xFF6C63FF);
  static const Color secondaryColor = Color(0xFF4F46E5);
  static const Color successColor = Color(0xFF10B981);
  static const Color errorColor = Color(0xFFEF4444);
  static const Color backgroundColor = Color(0xFFF8FAFC);
  static const Color cardColor = Colors.white;
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color borderColor = Color(0xFFE2E8F0);

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
  void initState() {
    super.initState();
  }

  Future<void> initializeDB() async {
    db = await dbHelper.database;
  }

  void _navigateToAddExpense(String cas) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddExpensePage(from: cas)),
    ).then((_) {
      // Refresh data when returning from AddExpensePage
      if (mounted) {
        // Add any data refresh logic here if needed
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header Section
            SliverAppBar(
              backgroundColor: backgroundColor,
              elevation: 0,
              floating: true,
              pinned: false,
              title: Text('Dashboard', style: heading1.copyWith(fontSize: 24)),
              leading: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.menu, color: textPrimary, size: 22),
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
                          color: Colors.black.withOpacity(0.05),
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

            // Custom Scroll
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (sumOfCashExpense != '0.00' ||
                        sumOfOnlineExpense != '0.00') ...[
                      Text('Today Total Expense', style: heading3),
                      const SizedBox(height: 16),
                      PieChart(
                        dataMap: {
                          'Online': double.parse(sumOfOnlineExpense),
                          'Cash': double.parse(sumOfCashExpense),
                        },
                        animationDuration: const Duration(milliseconds: 800),
                        chartLegendSpacing: 40,
                        chartRadius: MediaQuery.of(context).size.width / 3.2,
                        colorList: [primaryColor, secondaryColor],
                        initialAngleInDegree: 30,
                        chartType: ChartType.ring,
                        ringStrokeWidth: 25,
                        centerText: 'Expenses',
                        legendOptions: LegendOptions(
                          showLegendsInRow: false,
                          legendPosition: LegendPosition.right,
                          showLegends: true,
                          legendTextStyle: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        chartValuesOptions: ChartValuesOptions(
                          showChartValues: true,
                          showChartValuesInPercentage: true,
                          showChartValuesOutside: true,
                          showChartValueBackground: true,
                          chartValueBackgroundColor: Colors.transparent
                              .withOpacity(0.1),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                    if (listOfPassBookEntry.isNotEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Recent Transactions', style: heading3),
                          TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'See All',
                              style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: listOfPassBookEntry.length,
                        itemBuilder: (context, index) {
                          final item = listOfPassBookEntry[index];
                          final isCredit =
                              item['transaction_method'] == 'credit';
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 2,
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: isCredit
                                    ? successColor.withOpacity(0.2)
                                    : errorColor.withOpacity(0.2),
                                child: Icon(
                                  isCredit
                                      ? Icons.arrow_downward
                                      : Icons.arrow_upward,
                                  color: isCredit ? successColor : errorColor,
                                ),
                              ),
                              title: Text(
                                item['category'].toString(),
                                style: heading3,
                              ),
                              subtitle: Text(
                                '${item['time']} • ${item['date']}',
                                style: bodySmall,
                              ),
                              trailing: Text(
                                '${isCredit ? '+' : '-'} ₹${item['amount']}',
                                style: GoogleFonts.poppins(
                                  color: isCredit ? successColor : errorColor,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        TransactionDetails(transaction: item),
                                  ),
                                );
                              },
                            ),
                          );
                        },
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
                          padding: const EdgeInsets.symmetric(vertical: 16),
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
                          padding: const EdgeInsets.symmetric(vertical: 16),
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
            color: Colors.black.withOpacity(0.05),
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
                      padding: EdgeInsets.only(
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
                      padding: EdgeInsets.only(
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
                      padding: EdgeInsets.only(
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
                      padding: EdgeInsets.only(
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
                        padding: EdgeInsets.only(
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

  void getCurrentBalance() async {
    int month = DateTime.now().month;
    int year = DateTime.now().year;
    String sd = DateFormat("yyyy-MM-dd").format(DateTime(year, month, 1));
    String ed = DateFormat(
      "yyyy-MM-dd",
    ).format(DateTime(year, month + 1, 1).subtract(Duration(days: 1)));
    var list = await dbHelper.retrieveListOfPassBookEntry(db);
    var cB = await dbHelper.retrieveMonthlyBalance(db, sd, ed, "credit");
    var dB = await dbHelper.retrieveMonthlyBalance(db, sd, ed, "debit");
    setState(() {
      listOfPassBookEntry = list;
      cBalance = cB;
      dBalance = dB;
    });
  }

  Future<void> _showMyDialog() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          elevation: 10,
          title: Text("Insufficient Balance", style: heading2),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "you have Insufficient Balance! Please SetUp Initial Account",
                  style: bodyMedium,
                ),
              ],
            ),
          ),
          actions: [
            Container(
              height: 30,
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("OK"),
              ),
            ),
          ],
        );
      },
    );
  }
}
