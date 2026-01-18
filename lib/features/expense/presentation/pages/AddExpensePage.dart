import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_manager/core/service/impl/local_storage_service.dart';
import 'package:expense_manager/features/expense/domain/entities/expense_entity.dart';
import 'package:expense_manager/features/expense/domain/repositories/expense_repository.dart';
import 'package:expense_manager/features/user/domain/entities/user_entity.dart';
import 'package:expense_manager/features/user/domain/repositories/user_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/service/i_local_storage_service.dart';
import '../bloc/expense_bloc.dart';
import '../bloc/expense_event.dart';
import '../bloc/expense_state.dart';

class AddExpensePage extends StatefulWidget {
  final String from;

  const AddExpensePage({Key? key, required this.from}) : super(key: key);

  @override
  _AddExpensePageState createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dateController = TextEditingController(
    text: DateFormat('MMM dd, yyyy').format(DateTime.now()),
  );

  String _selectedCategory = 'Food';
  String _selectedPaymentMethod = 'Cash';
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  final List<Map<String, dynamic>> _paymentMethods = [
    {'name': 'Cash', 'icon': Icons.currency_rupee_outlined},
    {'name': 'Credit Card', 'icon': Icons.credit_card},
    {'name': 'Debit Card', 'icon': Icons.credit_card},
    {'name': 'UPI', 'icon': Icons.payment_outlined},
    {'name': 'Bank Transfer', 'icon': Icons.account_balance},
    {'name': 'Digital Wallet', 'icon': Icons.account_balance_wallet},
  ];

  final List<Map<String, dynamic>> _categories = [
    {
      'name': 'Food',
      'icon': Icons.restaurant,
      'color': const Color(0xFFFF6B6B),
    },
    {
      'name': 'Transport',
      'icon': Icons.directions_car,
      'color': const Color(0xFF4D96FF),
    },
    {
      'name': 'Shopping',
      'icon': Icons.shopping_bag,
      'color': const Color(0xFF6C5CE7),
    },
    {'name': 'Bills', 'icon': Icons.receipt, 'color': const Color(0xFF00B894)},
    {
      'name': 'Entertainment',
      'icon': Icons.movie,
      'color': const Color(0xFFFD79A8),
    },
    {
      'name': 'Health',
      'icon': Icons.health_and_safety,
      'color': const Color(0xFF00CEC9),
    },
    {
      'name': 'Education',
      'icon': Icons.school,
      'color': const Color(0xFF6C5CE7),
    },
    {
      'name': 'Other',
      'icon': Icons.more_horiz,
      'color': const Color(0xFFA4B0BE),
    },
  ];

  final List<Map<String, dynamic>> _incomeCategories = [
    {'name': 'Rent', 'icon': Icons.house, 'color': const Color(0xFFFF6B6B)},
    {
      'name': 'Gift',
      'icon': Icons.card_giftcard,
      'color': const Color(0xFF4D96FF),
    },
    {
      'name': 'Cashback',
      'icon': Icons.payments_outlined,
      'color': const Color(0xFF6C5CE7),
    },
    {'name': 'Salary', 'icon': Icons.receipt, 'color': const Color(0xFF00B894)},
    {
      'name': 'Other',
      'icon': Icons.more_horiz,
      'color': const Color(0xFFA4B0BE),
    },
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF6C63FF),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1E293B),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('MMM dd, yyyy').format(picked);
      });
    }
  }

  final _uuid = const Uuid();

  @override
  Widget build(BuildContext context) {
    return BlocListener<ExpenseBloc, ExpenseState>(
      listener: (context, state) {
        if (state is ExpenseSuccess) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Saved successfully')),
          );
        }

        if (state is ExpenseError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: BlocBuilder<ExpenseBloc, ExpenseState>(
        builder: (context, state) {
          final isLoading = state is ExpenseLoading;

          return widget.from == 'spend'
              ? _buildExpenseUI(context, isLoading)
              : _buildIncomeUI(context, isLoading);
        },
      ),
    );
  }


  Widget _buildExpenseUI(BuildContext context, bool isLoading) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Expense', style: GoogleFonts.poppins()),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildForm(context, 'spend'),
    );
  }

  Future<void> _submitForm(String from) async {
    if (!_formKey.currentState!.validate()) return;

    final expense = ExpenseEntity(
      id: _uuid.v4(),
      title: _descriptionController.text.isNotEmpty
          ? _descriptionController.text
          : _selectedCategory,
      amount: double.parse(_amountController.text),
      date: _selectedDate,
      category: _selectedCategory,
      description: _descriptionController.text,
      receiptImagePath: null,
      userId: await sl<ILocalStorageService>().userId ?? '',
      familyId: await sl<ILocalStorageService>().familyId ?? '',
    );

    context.read<ExpenseBloc>().add(AddExpenseEvent(expense: expense));
  }

}
