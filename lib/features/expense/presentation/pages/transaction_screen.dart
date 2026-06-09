import 'package:expense_manager/core/constants/expense_categories.dart';
import 'package:expense_manager/features/expense/domain/entities/expense_category_entity.dart';
import 'package:expense_manager/features/expense/domain/entities/payment_category.dart';
import 'package:expense_manager/features/expense/presentation/bloc/expense_bloc.dart';
import 'package:expense_manager/features/expense/presentation/bloc/expense_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/payment_categories.dart';
import '../../domain/entities/expense.dart';
import '../bloc/expense_state.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String searchQuery = '';
  String selectedCategory = 'All';
  String selectedPayment = 'All';

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

    final index = _tabController.index;
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'Transactions',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: const Color(0xFF6C63FF).withValues(alpha: 0.1),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          labelColor: const Color(0xFF6C63FF),
          unselectedLabelColor: Colors.grey,
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          unselectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500),
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Expense'),
            Tab(text: 'Income'),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildSearch(),
          _buildFilters(),
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
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        onChanged: (value) {
          setState(() => searchQuery = value);
        },
        decoration: InputDecoration(
          hintText: 'Search transaction...',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _chipRow<ExpenseCategory>(
            'Category',
            _tabController.index == 0
                ? [ "All",
                    ...ExpenseCategories.income.map((e) => e.name).toList(),
                    ...ExpenseCategories.spend.map((e) => e.name).toList(),
                  ]
                : _tabController.index == 1
                ? ["All", ...ExpenseCategories.spend.map((e) => e.name).toList()]
                : ["All", ...ExpenseCategories.income.map((e) => e.name).toList()],
            selectedCategory,
            (value) => setState(() => selectedCategory = value),
          ),
          const SizedBox(height: 8),
          _chipRow<PaymentCategory>(
            'Payment',
            ["All", ...paymentCategories.map((e) =>e.name).toList()],
            selectedPayment,
            (value) => setState(() => selectedPayment = value),
          ),
        ],
      ),
    );
  }

  Widget _chipRow<T>(
    String title,
    List<String> items,
    String selected,
    ValueChanged<String> onSelected,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final item = items[index];
              final isSelected = item == selected;

              return ChoiceChip(
                label: Text(item),
                selected: isSelected,
                selectedColor: const Color(0xFF6C63FF),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                ),
                onSelected: (_) => onSelected(item),
              );
            },
          ),
        ),
      ],
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
            padding: const EdgeInsets.all(16),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final tx = filtered[index];
              return _transactionTile(
                title: tx.title,
                category: tx.category,
                amount: tx.amount,
                payment: tx.paymentMethod,
                date: tx.date!,
              );
            },
          );
        }

        return const SizedBox();
      },
    );
  }

  Widget _transactionTile({
    required String title,
    required String category,
    required double amount,
    required String payment,
    required DateTime date,
  }) {
    final isExpense = amount < 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: isExpense
              ? Colors.red.withOpacity(0.15)
              : Colors.green.withOpacity(0.15),
          child: Icon(
            isExpense ? Icons.arrow_upward : Icons.arrow_downward,
            color: isExpense ? Colors.red : Colors.green,
          ),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '$category • $payment • ${DateFormat('dd MMM yyyy').format(date)}',
          style: GoogleFonts.poppins(fontSize: 12),
        ),
        trailing: Text(
          '${isExpense ? '-' : '+'} ₹${amount.abs().toStringAsFixed(2)}',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: isExpense ? Colors.red : Colors.green,
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
      if (selectedCategory != 'All' && tx.category != selectedCategory) {
        return false;
      }

      // Payment filter
      if (selectedPayment != 'All' && tx.paymentMethod != selectedPayment) {
        return false;
      }

      return true;
    }).toList();
  }
}
