import 'package:expense_manager/core/extensions/theme_extension.dart';
import 'package:expense_manager/features/expense/domain/entities/expense_category_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../core/constants/expense_categories.dart';
import '../../../../core/constants/payment_categories.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/service/i_local_storage_service.dart';
import '../../domain/entities/expense.dart';
import '../bloc/expense_bloc.dart';
import '../bloc/expense_event.dart';
import '../bloc/expense_state.dart';

class AddExpenseScreen extends StatefulWidget {
  final String from;

  const AddExpenseScreen({Key? key, required this.from}) : super(key: key);

  @override
  _AddExpenseScreenState createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dateController = TextEditingController(
    text: DateFormat('MMM dd, yyyy HH:mm').format(DateTime.now()),
  );

  String _selectedCategory = 'Food';
  String _selectedPaymentMethod = 'Cash';
  DateTime _selectedDate = DateTime.now();
  String? _receiptImagePath;

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
    final DateTime? pickedDate = await showDatePicker(
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
    if (pickedDate != null && context.mounted) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
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
      if (pickedTime != null) {
        setState(() {
          _selectedDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          _dateController.text = DateFormat('MMM dd, yyyy HH:mm').format(_selectedDate);
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _receiptImagePath = image.path;
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
        title: const Text('Add Expense'),
        centerTitle: true,
        leading: IconButton(
          icon: const HugeIcon(icon: HugeIcons.strokeRoundedArrowLeft01, color: Colors.black),
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
        title: const Text('Add Income'),
        centerTitle: true,
        leading: IconButton(
          icon: const HugeIcon(icon: HugeIcons.strokeRoundedArrowLeft01, color: Colors.black),
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
      padding: const EdgeInsets.symmetric(horizontal: 20),
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
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                    decoration: _inputDecoration(
                      icon: HugeIcons.strokeRoundedMoney01,
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
                    decoration: _inputDecoration(icon: HugeIcons.strokeRoundedCalendar01),
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
                    _buildPaymentCategoryGrid(),
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
                      icon: HugeIcons.strokeRoundedNote01,
                      hintText: "Describe you payment here",
                    ),
                  ),
                ],
              ),
            ),

            _gap(),

            /// Attachment Card
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle('Attachment (Receipt/Invoice)'),
                  const SizedBox(height: 12),
                  if (_receiptImagePath != null)
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(_receiptImagePath!),
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          right: 8,
                          top: 8,
                          child: GestureDetector(
                            onTap: () => setState(() => _receiptImagePath = null),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const HugeIcon(icon: HugeIcons.strokeRoundedCancel01, color: Colors.white, size: 20),
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    InkWell(
                      onTap: _pickImage,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: 100,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300, width: 2),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey.shade50,
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            HugeIcon(icon: HugeIcons.strokeRoundedImageAdd01, size: 32, color: Colors.grey),
                            SizedBox(height: 8),
                            Text('Attach Image', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
                          ],
                        ),
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
                  HugeIcon(
                    icon: category.icon,
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

  Widget _buildPaymentCategoryGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: paymentCategories.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        final method = paymentCategories[index];
        final isSelected = _selectedPaymentMethod == method.name;

        return AnimatedScale(
          duration: const Duration(milliseconds: 200),
          scale: isSelected ? 1.05 : 1,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedPaymentMethod = method.name;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              decoration: BoxDecoration(
                color: isSelected ? method.color : Colors.white,
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
                  HugeIcon(
                    icon: method.icon,
                    size: 22,
                    color: isSelected ? Colors.white : method.color,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    method.name,
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
        color: context.theme.cardColor,
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
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
    );
  }

  InputDecoration _inputDecoration({
    required dynamic icon,
    bool inputBorder = true,
    String? hintText,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Colors.grey),

      floatingLabelBehavior: FloatingLabelBehavior.never,

      prefixIcon: HugeIcon(icon: icon, color: Colors.grey),

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

    final expense = Expense(
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
      receiptImagePath: _receiptImagePath,
      userId: await sl<ILocalStorageService>().userId ?? '',
      familyId: await sl<ILocalStorageService>().familyId ?? '',
      paymentMethod: _selectedPaymentMethod,
    );

    context.read<ExpenseBloc>().add(AddExpenseEvent(expense: expense));
  }
}
