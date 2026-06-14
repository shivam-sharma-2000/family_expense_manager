import 'package:expense_manager/core/extensions/theme_extension.dart';
import 'package:expense_manager/core/service/i_local_storage_service.dart';
import 'package:expense_manager/core/widgets/drawer.dart';
import 'package:expense_manager/features/expense/presentation/widgets/bar_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/routes/my_app_router_const.dart';
import '../../../../core/theme/bloc/theme_bloc.dart';
import '../../../../core/theme/bloc/theme_event.dart';
import '../../../../core/theme/bloc/theme_state.dart';
import '../../../expense/domain/entities/expense.dart';
import '../../../expense/presentation/bloc/expense_bloc.dart';
import '../../../expense/presentation/bloc/expense_event.dart';
import '../../../expense/presentation/bloc/expense_state.dart';
import '../../../user/domain/entities/user_entity.dart';
import '../../../user/presentation/bloc/user_bloc.dart';
import '../../../user/presentation/bloc/user_state.dart';
import '../../../user/presentation/bloc/user_event.dart';
import '../../../user/domain/repositories/user_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../expense/presentation/screens/transaction_details.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double cBalance = 0;
  double dBalance = 0;

  late Database db;
  String sumOfOnlineExpense = "0.00";
  String sumOfCashExpense = "0.00";

  String sumOfOnlineIncome = "0.00";
  String sumOfCashIncome = "0.00";

  late List<Expense> listOfRecentTransaction = [];
  bool isFamilyMode = false;
  String? selectedFamilyMemberId;
  List<UserEntity> familyMembers = [];

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void dispose() {
    // _expensesSubscription?.cancel();
    // _connectivitySubscription?.cancel();
    super.dispose();
  }

  late final expenseBloc = context.read<ExpenseBloc>();
  late final ILocalStorageService localStorageService;

  @override
  void initState() {
    super.initState();
    localStorageService = sl<ILocalStorageService>();
    _loadInitialData();
  }

  void _loadInitialData() {
    expenseBloc.add(const SyncExpenseEvent()); // Trigger a sync

    final userBloc = context.read<UserBloc>();
    if (userBloc.state is UserInitial) {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        userBloc.add(LoadUserEvent(userId));
      }
    } else {
      _handleUserState(userBloc.state);
    }
  }

  void _handleUserState(UserState userState) async {
    if (userState is UserLoaded) {
      final familyId = userState.user.familyId;
      if (familyId != null && familyId.isNotEmpty) {
        if (!isFamilyMode) {
          setState(() {
            isFamilyMode = true; // Default to family mode if user has family
          });
        }
        await _fetchFamilyMembers(familyId);
      }
      _dispatchLoadExpenses(familyId);
    }
  }

  void _dispatchLoadExpenses(String? familyId) {
    expenseBloc.add(
      LoadExpensesEvent(
        isFamilyMode: isFamilyMode,
        targetUserId: selectedFamilyMemberId,
        targetUserIds: familyMembers.map((e) => e.id).toList(),
        familyId: familyId,
      ),
    );
  }

  Future<void> _fetchFamilyMembers(String? familyId) async {
    if (familyId == null || familyId.isEmpty) return;
    try {
      final userRepo = sl<UserRepository>();
      final members = await userRepo.getUsersByFamilyId(familyId);
      if (mounted) {
        setState(() {
          familyMembers = members;
        });
      }
    } catch (e) {
      debugPrint("Failed to fetch family members: $e");
    }
  }

  void _toggleMode(bool toFamily, String? familyId) {
    setState(() {
      isFamilyMode = toFamily;
      selectedFamilyMemberId = null; // Reset selection
    });
    _dispatchLoadExpenses(familyId);
  }

  void _selectMember(String? memberId, String? familyId) {
    setState(() {
      selectedFamilyMemberId = memberId;
    });
    _dispatchLoadExpenses(familyId);
  }

  void _navigateToAddExpense(String cas) {
    context.push("${MyAppRouteConst.addExpense}/$cas");
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<UserBloc, UserState>(
          listener: (context, userState) {
            _handleUserState(userState);
          },
        ),
        BlocListener<ExpenseBloc, ExpenseState>(
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
              _loadInitialData();
            }
          },
        ),
      ],
      child: BlocBuilder<ExpenseBloc, ExpenseState>(
        builder: (context, state) {
          final userState = context.watch<UserBloc>().state;
          final currentUser = userState is UserLoaded ? userState.user : null;
          final hasFamily =
              currentUser?.familyId != null &&
              currentUser!.familyId!.isNotEmpty;

          return Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              leading: IconButton(
                icon: Padding(
                  padding: const EdgeInsets.all(8),
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedMenu01,
                    size: 22,
                    color: context.theme.colorScheme.onSurface,
                  ),
                ),
                onPressed: () {
                  // open drawer
                  _scaffoldKey.currentState?.openDrawer();
                },
              ),
              actions: [
                BlocBuilder<ThemeBloc, ThemeState>(
                  builder: (context, themeState) {
                    final isDark =
                        themeState.themeMode == ThemeMode.dark ||
                        (themeState.themeMode == ThemeMode.system &&
                            WidgetsBinding
                                    .instance
                                    .platformDispatcher
                                    .platformBrightness ==
                                Brightness.dark);
                    return IconButton(
                      icon: Padding(
                        padding: const EdgeInsets.all(8),
                        child: HugeIcon(
                          icon: isDark
                              ? HugeIcons.strokeRoundedSun01
                              : HugeIcons.strokeRoundedMoon02,
                          size: 24,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      onPressed: () {
                        context.read<ThemeBloc>().add(const ToggleThemeEvent());
                      },
                    );
                  },
                ),
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    child: HugeIcon(
                      icon: HugeIcons.strokeRoundedNotification01,
                      size: 24,
                      color: context.theme.colorScheme.onSurface,
                    ),
                  ),
                  onPressed: () {},
                ),
              ],
            ),
            drawer: const HomeDrawer(),
            body: RefreshIndicator(
              onRefresh: () async {
                _loadInitialData();
                return Future.delayed(const Duration(seconds: 1));
              },
              backgroundColor: context.theme.scaffoldBackgroundColor,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile Card
                      Text(
                        'Welcome back',
                        style: context.theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Shivam Sharma',
                        style: context.theme.textTheme.headlineMedium,
                      ),

                      const SizedBox(height: 20),

                      // Family / Individual Toggle
                      if (hasFamily) ...[
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: context.theme.cardColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () =>
                                      _toggleMode(false, currentUser.familyId),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: !isFamilyMode
                                          ? context.theme.colorScheme.primary
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'Individual',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.poppins(
                                        color: !isFamilyMode
                                            ? Colors.white
                                            : context
                                                  .theme
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.color,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () =>
                                      _toggleMode(true, currentUser.familyId),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isFamilyMode
                                          ? context.theme.colorScheme.primary
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'Family',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.poppins(
                                        color: isFamilyMode
                                            ? Colors.white
                                            : context
                                                  .theme
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.color,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Family Filter Chips
                      if (hasFamily && isFamilyMode && familyMembers.isNotEmpty)
                        SizedBox(
                          height: 40,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  label: Text(
                                    'All Family',
                                    style: GoogleFonts.poppins(),
                                  ),
                                  selected: selectedFamilyMemberId == null,
                                  onSelected: (selected) {
                                    if (selected) {
                                      _selectMember(null, currentUser.familyId);
                                    }
                                  },
                                ),
                              ),
                              ...familyMembers.map((member) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: ChoiceChip(
                                    label: Text(
                                      member.name,
                                      style: GoogleFonts.poppins(),
                                    ),
                                    selected:
                                        selectedFamilyMemberId == member.id,
                                    onSelected: (selected) {
                                      if (selected) {
                                        _selectMember(
                                          member.id,
                                          currentUser.familyId,
                                        );
                                      }
                                    },
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        ),

                      // Income and Expense Summary
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildSummaryCard(
                            'Monthly Income',
                            cBalance,
                            context.theme.colorScheme.secondary,
                            HugeIcons.strokeRoundedArrowDown01,
                          ),
                          const SizedBox(width: 20),
                          _buildSummaryCard(
                            'Monthly Expense',
                            dBalance,
                            context.theme.colorScheme.error,
                            HugeIcons.strokeRoundedArrowUp01,
                          ),
                        ],
                      ),

                      // Recent Transactions Section
                      const SizedBox(height: 20),

                      if (state is ExpenseLoading) ...[
                        const Center(child: CircularProgressIndicator()),
                        const SizedBox(height: 20),
                      ] else if (state is ExpenseLoaded) ...[
                        // Expense Summary
                        if (state.expenseSummary.expenseByCategory.isNotEmpty)
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: context.theme.cardColor,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(top: 15),
                              child: Column(
                                children: [
                                  Text(
                                    'Top Five Expenses',
                                    style:
                                        context.theme.textTheme.headlineSmall,
                                  ),
                                  const SizedBox(height: 16),
                                  ExpenseBarChart(
                                    categoryCase: 'expense',
                                    categoryTotals:
                                        state.expenseSummary.expenseByCategory,
                                  ),
                                ],
                              ),
                            ),
                          ),

                        const SizedBox(height: 20),

                        if (state.expenseSummary.incomeByCategory.isNotEmpty)
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: context.theme.cardColor,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(top: 15),
                              child: Column(
                                children: [
                                  Text(
                                    'Top Five Incomes',
                                    style:
                                        context.theme.textTheme.headlineSmall,
                                  ),
                                  const SizedBox(height: 16),
                                  ExpenseBarChart(
                                    categoryCase: 'income',
                                    categoryTotals:
                                        state.expenseSummary.incomeByCategory,
                                  ),
                                ],
                              ),
                            ),
                          ),

                        const SizedBox(height: 20),

                        // Recent Transactions
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Recent Transactions',
                              style: context.theme.textTheme.headlineSmall,
                            ),
                            TextButton(
                              onPressed: () {
                                // Navigate to all transactions screen
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'See All',
                                style: TextStyle(
                                  color: context.theme.primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (state.expenses.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 32.0),
                            child: Center(child: Text('No transactions yet')),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: state.expenses.take(5).length,
                            itemBuilder: (context, index) {
                              final expense = state.expenses[index];
                              final isExpense = expense.amount < 0;

                              return DecoratedBox(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.04,
                                      ),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  leading: CircleAvatar(
                                    backgroundColor: isExpense
                                        ? context.theme.colorScheme.error
                                              .withValues(alpha: 0.2)
                                        : context.theme.colorScheme.secondary
                                              .withValues(alpha: 0.2),
                                    child: HugeIcon(
                                      icon: isExpense
                                          ? HugeIcons.strokeRoundedArrowUp01
                                          : HugeIcons.strokeRoundedArrowDown01,
                                      color: isExpense
                                          ? context.theme.colorScheme.error
                                          : context.theme.colorScheme.secondary,
                                    ),
                                  ),
                                  title: Text(
                                    expense.category,
                                    style: context.theme.textTheme.headlineSmall
                                        ?.copyWith(fontSize: 16),
                                  ),
                                  subtitle: (expense.date != null)
                                      ? Text(
                                          DateFormat(
                                            'MMM dd, yyyy',
                                          ).format(expense.date!),
                                          style:
                                              context.theme.textTheme.bodySmall,
                                        )
                                      : const SizedBox.shrink(),
                                  trailing: Text(
                                    '${isExpense ? '-' : '+'} \$${expense.amount.abs().toStringAsFixed(2)}',
                                    style: GoogleFonts.poppins(
                                      color: isExpense
                                          ? context.theme.colorScheme.error
                                          : context.theme.colorScheme.secondary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            TransactionDetails(
                                              transaction: {
                                                'amount': expense.amount,
                                                'category': expense.category,
                                                'transaction_method':
                                                    expense.paymentMethod,
                                                'entry_id': expense.id,
                                                'date': expense.date
                                                    ?.toIso8601String(),
                                                'receipt_image_path':
                                                    expense.receiptImagePath,
                                              },
                                            ),
                                      ),
                                    );
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
                              HugeIcon(
                                icon: HugeIcons.strokeRoundedAlert02,
                                color: context.theme.colorScheme.error,
                                size: 48,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Failed to load expenses',
                                style: context.theme.textTheme.headlineSmall
                                    ?.copyWith(
                                      color: context.theme.colorScheme.error,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                state.message,
                                style: context.theme.textTheme.bodyMedium,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () =>
                                    expenseBloc.add(const LoadExpensesEvent()),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: kToolbarHeight),
                    ],
                  ),
                ),
              ),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            floatingActionButton: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _navigateToAddExpense('spend');
                      },
                      icon: const HugeIcon(
                        icon: HugeIcons.strokeRoundedArrowUp01,
                        color: Colors.white,
                      ),
                      label: Text(
                        'Spend',
                        style: context.theme.textTheme.bodyMedium,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.theme.colorScheme.error,
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
                      icon: const HugeIcon(
                        icon: HugeIcons.strokeRoundedArrowDown01,
                        color: Colors.white,
                      ),
                      label: Text(
                        'Receive',
                        style: context.theme.textTheme.bodyMedium,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.theme.colorScheme.secondary,
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
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    double amount,
    Color color,
    dynamic icon,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: context.theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            HugeIcon(icon: icon, size: 36, color: color),
            const SizedBox(height: 12),
            Text(title, style: context.theme.textTheme.bodyMedium),
            const SizedBox(height: 8),
            Text(
              '₹${amount.toStringAsFixed(2)}',
              style: context.theme.textTheme.headlineMedium?.copyWith(
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void getDailyExpense() async {
    // double total = await dbHelper.retrieveTodayExpense(db, "online");
    double total = 0;
    if (total != 0) {
      setState(() {
        sumOfOnlineExpense = total.toString();
      });
    }
    // total = await dbHelper.retrieveTodayExpense(db, "cash");
    total = 0;
    if (total != 0) {
      setState(() {
        sumOfCashExpense = total.toString();
      });
    }
  }

  void getIncomes() async {
    // double total = await dbHelper.retrieveTotalIncome(db, "online");
    double total = 0;
    if (total != 0) {
      setState(() {
        sumOfOnlineIncome = total.toString();
      });
    }
    // total = await dbHelper.retrieveTodayExpense(db, "cash");
    total = 0;
    if (total != 0) {
      setState(() {
        sumOfCashIncome = total.toString();
      });
    }
  }

  void getTodayIncomes() async {
    double total = 0;
    // double total = await dbHelper.retrieveTodayIncome(db, "online");
    if (total != 0) {
      setState(() {
        sumOfOnlineIncome = total.toString();
      });
    }
    total = 0;
    // total = await dbHelper.retrieveTodayIncome(db, "cash");
    if (total != 0) {
      setState(() {
        sumOfCashIncome = total.toString();
      });
    }
  }
}
