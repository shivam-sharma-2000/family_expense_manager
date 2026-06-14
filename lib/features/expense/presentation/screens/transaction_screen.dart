import 'package:expense_manager/core/constants/expense_categories.dart';
import 'package:expense_manager/core/extensions/theme_extension.dart';
import 'package:expense_manager/features/expense/presentation/bloc/expense_bloc.dart';
import 'package:expense_manager/features/expense/presentation/bloc/expense_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/constants/payment_categories.dart';
import '../../domain/entities/expense.dart';
import '../bloc/expense_state.dart';
import 'transaction_details.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String searchQuery = '';
  Set<String> selectedCategories = {};
  Set<String> selectedPayments = {};

  late final expenseBloc = context.read<ExpenseBloc>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_tabListener);
    context.read<ExpenseBloc>().add(const LoadExpensesEvent());
  }

  void _tabListener() {
    // Fires multiple times while animating
    if (_tabController.indexIsChanging) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'Transactions',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          labelColor: const Color(0xFF6C63FF),
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          unselectedLabelStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
          ),
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Expense'),
            Tab(text: 'Income'),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildSearch(),
            const SizedBox(height: 20),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _transactionList(),
                  _transactionList(type: 'expense'),
                  _transactionList(type: 'income'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearch() {
    return TextField(
      onChanged: (value) {
        setState(() => searchQuery = value);
      },
      decoration: InputDecoration(
        hintText: 'Search transaction...',
        prefixIcon: const HugeIcon(
          icon: HugeIcons.strokeRoundedSearch01,
          color: Colors.grey,
        ),
        suffixIcon: IconButton(
          icon: const HugeIcon(
            icon: HugeIcons.strokeRoundedFilter,
            color: Colors.grey,
          ),
          onPressed: _showFilterBottomSheet,
        ),
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  void _showFilterBottomSheet() {
    // Generate categories based on tab
    List<String> categories = [];
    if (_tabController.index == 0) {
      categories = [
        ...ExpenseCategories.income.map((e) => e.name),
        ...ExpenseCategories.spend.map((e) => e.name),
      ];
    } else if (_tabController.index == 1) {
      categories = ExpenseCategories.spend.map((e) => e.name).toList();
    } else {
      categories = ExpenseCategories.income.map((e) => e.name).toList();
    }

    final payments = paymentCategories.map((e) => e.name).toList();

    int selectedSectionIndex = 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.85,
              child: Column(
                children: [
                  // Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: context.theme.colorScheme.onSurface.withValues(
                            alpha: .1,
                          ),
                        ),
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Text(
                          'Filters',
                          style: TextStyle(
                            fontSize: 18,
                            color: context.theme.colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Positioned(
                          right: 20,
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: HugeIcon(
                              icon: HugeIcons.strokeRoundedCancel01,
                              color: context.theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Body
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left Section (Filter Names)
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.35,
                          child: ListView(
                            padding: EdgeInsets.zero,
                            children: [
                              _buildFilterSectionTile(
                                'Category',
                                0,
                                selectedSectionIndex,
                                (index) => setModalState(
                                  () => selectedSectionIndex = index,
                                ),
                              ),
                              _buildFilterSectionTile(
                                'Payment',
                                1,
                                selectedSectionIndex,
                                (index) => setModalState(
                                  () => selectedSectionIndex = index,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Right Section (Filter Values)
                        Expanded(
                          child: Container(
                            color: context.theme.colorScheme.surface,
                            child: ListView(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              children: selectedSectionIndex == 0
                                  ? _buildCustomCheckboxList(
                                      categories,
                                      selectedCategories,
                                      setModalState,
                                    )
                                  : _buildCustomCheckboxList(
                                      payments,
                                      selectedPayments,
                                      setModalState,
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Footer
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        top: BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              setState(() {}); // trigger main screen update
                              Navigator.pop(context);
                            },
                            child: const Text(
                              'Apply',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () {
                            setModalState(() {
                              selectedCategories.clear();
                              selectedPayments.clear();
                            });
                          },
                          child: const Text(
                            'Reset',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  List<Widget> _buildCustomCheckboxList(
    List<String> items,
    Set<String> selectedItems,
    StateSetter setModalState,
  ) {
    bool? isAllChecked;
    if (selectedItems.isEmpty) {
      isAllChecked = false;
    } else if (selectedItems.length == items.length) {
      isAllChecked = true;
    } else {
      isAllChecked = null;
    }

    final allTile = CheckboxListTile(
      value: isAllChecked,
      tristate: true,
      activeColor: context.theme.colorScheme.onSurface,
      checkColor: context.theme.colorScheme.surface,
      checkboxShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
      title: const Text('All'),
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
      onChanged: (checked) {
        setModalState(() {
          if (isAllChecked == false) {
            selectedItems.addAll(items);
          } else {
            selectedItems.clear();
          }
        });
      },
    );

    final itemTiles = items.map((item) {
      return CheckboxListTile(
        value: selectedItems.contains(item),
        activeColor: context.theme.colorScheme.onSurface,
        checkColor: context.theme.colorScheme.surface,
        checkboxShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        title: Text(item),
        contentPadding: EdgeInsets.zero,
        controlAffinity: ListTileControlAffinity.leading,
        onChanged: (checked) {
          setModalState(() {
            if (checked == true) {
              selectedItems.add(item);
            } else {
              selectedItems.remove(item);
            }
          });
        },
      );
    }).toList();

    return [allTile, ...itemTiles];
  }

  Widget _buildFilterSectionTile(
    String title,
    int index,
    int selectedIndex,
    ValueChanged<int> onTap,
  ) {
    final isSelected = index == selectedIndex;
    return InkWell(
      onTap: () => onTap(index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? context.theme.colorScheme.surface
              : Colors.transparent,
          border: isSelected ? const Border(left: BorderSide(width: 4)) : null,
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected
                ? context.theme.colorScheme.onSurface
                : context.theme.colorScheme.onSurface.withValues(alpha: .8),
          ),
        ),
      ),
    );
  }

  Widget _transactionList({String? type}) {
    return BlocBuilder<ExpenseBloc, ExpenseState>(
      builder: (context, state) {
        if (state is ExpenseLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ExpenseError) {
          return Center(child: Text(state.message));
        }

        if (state is ExpenseLoaded) {
          final filtered = _applyFilters(state.expenses, type);

          if (filtered.isEmpty) {
            return const Center(child: Text('No transactions found'));
          }

          return ListView.builder(
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final tx = filtered[index];
              return _transactionTile(
                context: context,
                id: tx.id,
                title: tx.title,
                category: tx.category,
                amount: tx.amount,
                payment: tx.paymentMethod,
                date: tx.date,
                receiptImagePath: tx.receiptImagePath,
              );
            },
          );
        }

        return const SizedBox();
      },
    );
  }

  Widget _transactionTile({
    required BuildContext context,
    required String id,
    required String title,
    required String category,
    required double amount,
    required String payment,
    required DateTime? date,
    required String? receiptImagePath,
  }) {
    final isExpense = amount < 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: context.theme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TransactionDetails(
                transaction: {
                  'amount': amount,
                  'category': category,
                  'transaction_method': payment,
                  'entry_id': id,
                  'date': date?.toIso8601String(),
                  'receipt_image_path': receiptImagePath,
                },
              ),
            ),
          );
        },
        leading: CircleAvatar(
          backgroundColor: isExpense
              ? context.theme.colorScheme.error.withValues(alpha: .1)
              : context.theme.colorScheme.secondary.withValues(alpha: .1),
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
          title,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '$category • $payment${date != null ? ' • ${DateFormat('dd MMM yyyy').format(date)}' : ''}',
          style: GoogleFonts.poppins(fontSize: 12),
        ),
        trailing: Text(
          '${isExpense ? '-' : '+'} ₹${amount.abs().toStringAsFixed(2)}',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: isExpense
                ? context.theme.colorScheme.error
                : context.theme.colorScheme.secondary,
          ),
        ),
      ),
    );
  }

  List<Expense> _applyFilters(List<Expense> expenses, String? type) {
    return expenses.where((tx) {
      final isExpense = tx.amount < 0;

      // Tab filter
      if (type == 'expense' && !isExpense) return false;
      if (type == 'income' && isExpense) return false;

      // Search filter
      if (searchQuery.isNotEmpty &&
          !tx.title.toLowerCase().contains(searchQuery.toLowerCase())) {
        return false;
      }

      // Category filter
      if (selectedCategories.isNotEmpty &&
          !selectedCategories.contains(tx.category)) {
        return false;
      }

      // Payment filter
      if (selectedPayments.isNotEmpty &&
          !selectedPayments.contains(tx.paymentMethod)) {
        return false;
      }

      return true;
    }).toList();
  }
}
