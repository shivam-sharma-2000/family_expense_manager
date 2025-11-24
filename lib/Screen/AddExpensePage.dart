import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_manager/model/ExpenseResModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

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
  User? user = FirebaseAuth.instance.currentUser;

  final List<Map<String, dynamic>> _paymentMethods = [
    {'name': 'Cash', 'icon': Icons.currency_rupee_outlined},
    {'name': 'Credit Card', 'icon': Icons.credit_card},
    {'name': 'Debit Card', 'icon': Icons.credit_card},
    {'name': 'UPI', 'icon': Icons.payment_outlined},
    {'name': 'Bank Transfer', 'icon': Icons.account_balance},
    {'name': 'Digital Wallet', 'icon': Icons.account_balance_wallet},
  ];

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Food', 'icon': Icons.restaurant, 'color': const Color(0xFFFF6B6B)},
    {'name': 'Transport', 'icon': Icons.directions_car, 'color': const Color(0xFF4D96FF)},
    {'name': 'Shopping', 'icon': Icons.shopping_bag, 'color': const Color(0xFF6C5CE7)},
    {'name': 'Bills', 'icon': Icons.receipt, 'color': const Color(0xFF00B894)},
    {'name': 'Entertainment', 'icon': Icons.movie, 'color': const Color(0xFFFD79A8)},
    {'name': 'Health', 'icon': Icons.health_and_safety, 'color': const Color(0xFF00CEC9)},
    {'name': 'Education', 'icon': Icons.school, 'color': const Color(0xFF6C5CE7)},
    {'name': 'Other', 'icon': Icons.more_horiz, 'color': const Color(0xFFA4B0BE)},
  ];

  final List<Map<String, dynamic>> _incomeCategories = [
    {'name': 'Rent', 'icon': Icons.house, 'color': const Color(0xFFFF6B6B)},
    {'name': 'Gift', 'icon': Icons.card_giftcard, 'color': const Color(0xFF4D96FF)},
    {'name': 'Cashback', 'icon': Icons.payments_outlined, 'color': const Color(0xFF6C5CE7)},
    {'name': 'Salary', 'icon': Icons.receipt, 'color': const Color(0xFF00B894)},
    {'name': 'Other', 'icon': Icons.more_horiz, 'color': const Color(0xFFA4B0BE)},
  ];

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

  Future<void> _submitForm(String from) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // TODO: Implement expense saving logic here
      // Example: await _expenseService.addExpense(...);
      
      // Simulate API call
      final model = await _firestore.collection('users').doc(user!.uid).get();
      final data = model.data() as Map<String, dynamic>;
      if(from == 'spend'){
        _saveExpenseToFirestore(ExpenseResModel(
          uuid: user!.uid,
          amount: _amountController.text.trim(),
          category: _selectedCategory,
          familyId: data['familyId'],
          method: _selectedPaymentMethod,
          note: _descriptionController.text.trim(),
          createdDate: FieldValue.serverTimestamp().toString(),
        ));
      }
      
      if (mounted) {
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to save expense: ${e.toString()}',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            backgroundColor: const Color(0xFFFF6B6B),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<void> _saveExpenseToFirestore(ExpenseResModel exp) async {
    final doc = _firestore.collection('expenses');
    await doc.add(exp.toJson());
  }

  @override
  Widget build(BuildContext context) {
    return widget.from == 'spend'
        ? Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Expense',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1E293B),
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF6C63FF)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF6C63FF)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Amount
                    Text(
                      'Amount',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF64748B),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E293B),
                      ),
                      decoration: InputDecoration(
                        // prefixText: '\$ ',
                        prefixIcon: const Icon(Icons.currency_rupee, color: Color(0xFF94A3B8),),
                        prefixStyle: GoogleFonts.poppins(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF6C63FF),
                        ),
                        hintText: '0.00',
                        hintStyle: GoogleFonts.poppins(
                          fontSize: 32,
                          color: const Color(0xFF94A3B8),
                        ),
                        border: InputBorder.none,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an amount';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Category Selection
                    Text(
                      'Category',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF64748B),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 10,
                      children: _categories.map((category){
                        final isSelected = _selectedCategory == category['name'];
                        return GestureDetector(
                          onTap: () => setState(() => _selectedCategory = category['name']),
                          child: Container(
                            width: 80,
                            child: Column(
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? category['color'].withOpacity(0.1)
                                        : const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(16),
                                    border: isSelected
                                        ? Border.all(color: category['color'], width: 2)
                                        : null,
                                  ),
                                  child: Icon(
                                    category['icon'],
                                    size: 28,
                                    color: isSelected
                                        ? category['color']
                                        : const Color(0xFF94A3B8),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  category['name'],
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: isSelected
                                        ? const Color(0xFF1E293B)
                                        : const Color(0xFF64748B),
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Payment Method
                    Text(
                      'Payment Method',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF64748B),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedPaymentMethod,
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF64748B)),
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF1E293B),
                            fontSize: 16,
                          ),
                          items: _paymentMethods.map((method) {
                            return DropdownMenuItem<String>(
                              value: method['name'],
                              child: Row(
                                children: [
                                  Icon(method['icon'], color: const Color(0xFF6C63FF), size: 20),
                                  const SizedBox(width: 12),
                                  Text(method['name']),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _selectedPaymentMethod = newValue;
                              });
                            }
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Description Input
                    TextFormField(
                      controller: _descriptionController,
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF1E293B),
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Add a note (optional)',
                        hintStyle: GoogleFonts.poppins(
                          color: const Color(0xFF94A3B8),
                          fontSize: 16,
                        ),
                        prefixIcon: const Icon(
                          Icons.notes_outlined,
                          color: Color(0xFF94A3B8),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF6C63FF)),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                      ),
                      maxLines: 3,
                      minLines: 1,
                    ),
                    const SizedBox(height: 16),

                    // Date Picker
                    TextFormField(
                      controller: _dateController,
                      readOnly: true,
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF1E293B),
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Select date',
                        hintStyle: GoogleFonts.poppins(
                          color: const Color(0xFF94A3B8),
                          fontSize: 16,
                        ),
                        prefixIcon: const Icon(
                          Icons.calendar_today_outlined,
                          color: Color(0xFF94A3B8),
                        ),
                        suffixIcon: const Icon(
                          Icons.keyboard_arrow_down,
                          color: Color(0xFF94A3B8),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF6C63FF)),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                      ),
                      onTap: () => _selectDate(context),
                    ),
                    const SizedBox(height: 32),

                    // Save Button
                    ElevatedButton(
                      onPressed: (){
                        _submitForm('spend');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C63FF),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Save Expense',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    )
        : Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Income',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1E293B),
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF6C63FF)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF6C63FF)))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Amount
              Text(
                'Amount',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF64748B),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
                decoration: InputDecoration(
                  // prefixText: '\$ ',
                  prefixIcon: const Icon(Icons.currency_rupee, color: Color(0xFF94A3B8),),
                  prefixStyle: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF6C63FF),
                  ),
                  hintText: '0.00',
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 32,
                    color: const Color(0xFF94A3B8),
                  ),
                  border: InputBorder.none,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Category Selection
              Text(
                'Category',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF64748B),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                children: _incomeCategories.map((category){
                  final isSelected = _selectedCategory == category['name'];
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = category['name']),
                    child: Container(
                      width: 80,
                      child: Column(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? category['color'].withOpacity(0.1)
                                  : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(16),
                              border: isSelected
                                  ? Border.all(color: category['color'], width: 2)
                                  : null,
                            ),
                            child: Icon(
                              category['icon'],
                              size: 28,
                              color: isSelected
                                  ? category['color']
                                  : const Color(0xFF94A3B8),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            category['name'],
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: isSelected
                                  ? const Color(0xFF1E293B)
                                  : const Color(0xFF64748B),
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Payment Method
              Text(
                'Payment Method',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF64748B),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedPaymentMethod,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF64748B)),
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF1E293B),
                      fontSize: 16,
                    ),
                    items: _paymentMethods.map((method) {
                      return DropdownMenuItem<String>(
                        value: method['name'],
                        child: Row(
                          children: [
                            Icon(method['icon'], color: const Color(0xFF6C63FF), size: 20),
                            const SizedBox(width: 12),
                            Text(method['name']),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedPaymentMethod = newValue;
                        });
                      }
                    },
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Description Input
              TextFormField(
                controller: _descriptionController,
                style: GoogleFonts.poppins(
                  color: const Color(0xFF1E293B),
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  hintText: 'Add a note (optional)',
                  hintStyle: GoogleFonts.poppins(
                    color: const Color(0xFF94A3B8),
                    fontSize: 16,
                  ),
                  prefixIcon: const Icon(
                    Icons.notes_outlined,
                    color: Color(0xFF94A3B8),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF6C63FF)),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                ),
                maxLines: 3,
                minLines: 1,
              ),
              const SizedBox(height: 16),

              // Date Picker
              TextFormField(
                controller: _dateController,
                readOnly: true,
                style: GoogleFonts.poppins(
                  color: const Color(0xFF1E293B),
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  hintText: 'Select date',
                  hintStyle: GoogleFonts.poppins(
                    color: const Color(0xFF94A3B8),
                    fontSize: 16,
                  ),
                  prefixIcon: const Icon(
                    Icons.calendar_today_outlined,
                    color: Color(0xFF94A3B8),
                  ),
                  suffixIcon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: Color(0xFF94A3B8),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF6C63FF)),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                ),
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 32),

              // Save Button
              ElevatedButton(
                onPressed: (){
                  _submitForm('receive');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Save Income',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
