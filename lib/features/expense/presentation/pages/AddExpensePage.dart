import 'package:expense_manager/features/expense/domain/entities/expense_category_entity.dart';
import 'package:expense_manager/features/expense/domain/entities/expense_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/expense_categories.dart';
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

  final List<Map<String, dynamic>> _paymentMethods = [
    {'name': 'Cash', 'icon': Icons.currency_rupee_outlined},
    {'name': 'Credit Card', 'icon': Icons.credit_card},
    {'name': 'Debit Card', 'icon': Icons.credit_card},
    {'name': 'UPI', 'icon': Icons.payment_outlined},
    {'name': 'Bank Transfer', 'icon': Icons.account_balance},
    {'name': 'Digital Wallet', 'icon': Icons.account_balance_wallet},
  ];

  // final List<Map<String, dynamic>> _categories = [
  //   {
  //     'name': 'Food',
  //     'icon': Icons.restaurant,
  //     'color': const Color(0xFFFF6B6B),
  //   },
  //   {
  //     'name': 'Transport',
  //     'icon': Icons.directions_car,
  //     'color': const Color(0xFF4D96FF),
  //   },
  //   {
  //     'name': 'Shopping',
  //     'icon': Icons.shopping_bag,
  //     'color': const Color(0xFF6C5CE7),
  //   },
  //   {'name': 'Bills', 'icon': Icons.receipt, 'color': const Color(0xFF00B894)},
  //   {
  //     'name': 'Entertainment',
  //     'icon': Icons.movie,
  //     'color': const Color(0xFFFD79A8),
  //   },
  //   {
  //     'name': 'Health',
  //     'icon': Icons.health_and_safety,
  //     'color': const Color(0xFF00CEC9),
  //   },
  //   {
  //     'name': 'Education',
  //     'icon': Icons.school,
  //     'color': const Color(0xFF6C5CE7),
  //   },
  //   {
  //     'name': 'Other',
  //     'icon': Icons.more_horiz,
  //     'color': const Color(0xFFA4B0BE),
  //   },
  // ];
  //
  // final List<Map<String, dynamic>> _incomeCategories = [
  //   {'name': 'Rent', 'icon': Icons.house, 'color': const Color(0xFFFF6B6B)},
  //   {
  //     'name': 'Gift',
  //     'icon': Icons.card_giftcard,
  //     'color': const Color(0xFF4D96FF),
  //   },
  //   {
  //     'name': 'Cashback',
  //     'icon': Icons.payments_outlined,
  //     'color': const Color(0xFF6C5CE7),
  //   },
  //   {'name': 'Salary', 'icon': Icons.receipt, 'color': const Color(0xFF00B894)},
  //   {
  //     'name': 'Other',
  //     'icon': Icons.more_horiz,
  //     'color': const Color(0xFFA4B0BE),
  //   },
  // ];

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
        if (state is AddExpenseSuccess) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Saved successfully')));
          context.pop();
        }

        if (state is ExpenseError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
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

  Widget _buildIncomeUI(BuildContext context, bool isLoading) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Income', style: GoogleFonts.poppins()),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildForm(context, 'income'),
    );
  }

  Widget _buildForm(BuildContext context, String from) {
    final categories = from == 'spend'
        ? ExpenseCategories.spend
        : ExpenseCategories.income;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            /// Amount Card
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle('Amount'),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.poppins(fontSize: 18),
                    decoration: _inputDecoration(
                      icon: Icons.currency_rupee,
                      inputBorder: false,
                      hintText: "0.00",
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Enter amount' : null,
                  ),
                ],
              ),
            ),

            _gap(),

            /// Date Card
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle('Date'),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _dateController,
                    readOnly: true,
                    onTap: () => _selectDate(context),
                    decoration: _inputDecoration(icon: Icons.calendar_today),
                  ),
                ],
              ),
            ),

            _gap(),

            /// Category
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle('Category'),
                  _gap(),
                  _buildCategoryGrid(categories),
                ],
              ),
            ),

            _gap(),

            /// Payment
            if (from == 'spend') ...[
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('Payment Method'),
                    _gap(),
                    _buildPaymentMethods(),
                    _gap(),
                  ],
                ),
              ),
            ],

            _gap(),

            /// Description
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle('Description'),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: _inputDecoration(
                      icon: Icons.notes,
                      hintText: "Describe you payment here",
                    ),
                  ),
                ],
              ),
            ),

            _gap(height: 32),

            /// CTA
            _submitButton(from),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryGrid(List<ExpenseCategory> categories) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: categories.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        final category = categories[index];
        final isSelected = _selectedCategory == category.name;

        return AnimatedScale(
          duration: const Duration(milliseconds: 200),
          scale: isSelected ? 1.05 : 1,
          child: GestureDetector(
            onTap: () {
              setState(() => _selectedCategory = category.name);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              decoration: BoxDecoration(
                color: isSelected ? category.color : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    category.icon,
                    size: 22,
                    color: isSelected ? Colors.white : category.color,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    category.name,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaymentMethods() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _paymentMethods.map((method) {
        final isSelected = _selectedPaymentMethod == method['name'];

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          child: ChoiceChip(
            showCheckmark: false,
            avatar: Icon(
              method['icon'],
              size: 18,
              color: isSelected ? Colors.white : Colors.black54,
            ),
            label: Text(method['name']),
            selected: isSelected,
            selectedColor: const Color(0xFF6C63FF),
            backgroundColor: Colors.white,
            onSelected: (_) {
              setState(() {
                _selectedPaymentMethod = method['name'];
              });
            },
            labelStyle: GoogleFonts.poppins(
              color: isSelected ? Colors.white : Colors.black,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _submitButton(String from) {
    return BlocBuilder<ExpenseBloc, ExpenseState>(
      builder: (context, state) {
        final isLoading = state is ExpenseLoading;

        return SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: isLoading ? null : () => _submitForm(from),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              elevation: isLoading ? 0 : 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: isLoading
                  ? const SizedBox(
                      key: ValueKey('loader'),
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      key: const ValueKey('text'),
                      from == 'spend' ? 'Add Expense' : 'Add Income',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _gap({double height = 20}) => SizedBox(height: height);

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required IconData icon,
    bool inputBorder = true,
    String? hintText,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Colors.grey),

      floatingLabelBehavior: FloatingLabelBehavior.never,

      prefixIcon: Icon(icon, color: Colors.grey),

      border: inputBorder
          ? OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            )
          : InputBorder.none,

      enabledBorder: inputBorder
          ? OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            )
          : InputBorder.none,

      focusedBorder: inputBorder
          ? OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            )
          : InputBorder.none,
    );
  }

  Future<void> _submitForm(String from) async {
    if (!_formKey.currentState!.validate()) return;

    final expense = ExpenseEntity(
      id: _uuid.v4(),
      title: _descriptionController.text.isNotEmpty
          ? _descriptionController.text
          : _selectedCategory,
      amount: from == 'spend'
          ? (double.parse(_amountController.text) * (-1))
          : double.parse(_amountController.text),
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
