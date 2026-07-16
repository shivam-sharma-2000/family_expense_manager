import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/extensions/theme_extension.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/tenant_payment_entity.dart';
import '../../domain/repositories/tenant_repository.dart';
import '../bloc/tenant_bloc.dart';
import '../bloc/tenant_detail_bloc.dart';

class AddPaymentScreen extends StatefulWidget {
  final String tenantId;
  final String billId;

  const AddPaymentScreen({
    super.key,
    required this.tenantId,
    required this.billId,
  });

  @override
  State<AddPaymentScreen> createState() => _AddPaymentScreenState();
}

class _AddPaymentScreenState extends State<AddPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _modeController = TextEditingController(text: 'Cash');
  final _transactionIdController = TextEditingController();
  final _repository = sl<TenantRepository>();

  DateTime _paymentDate = DateTime.now();
  bool _isLoading = false;

  final List<String> _modes = ['Cash', 'UPI', 'Bank Transfer'];

  @override
  void dispose() {
    _amountController.dispose();
    _modeController.dispose();
    _transactionIdController.dispose();
    super.dispose();
  }

  Future<void> _addPayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final tenantBloc = context.read<TenantBloc>();
    if (tenantBloc.state is! TenantLoaded) return;
    final tenant = (tenantBloc.state as TenantLoaded).tenants.firstWhere(
      (t) => t.id == widget.tenantId,
    );

    final payment = TenantPaymentEntity(
      id: const Uuid().v4(),
      propertyId: tenant.propertyId,
      billId: widget.billId,
      tenantId: widget.tenantId,
      amount: double.tryParse(_amountController.text) ?? 0.0,
      date: _paymentDate,
      method: _modeController.text,
      transactionId: _transactionIdController.text.trim(),
      createdAt: DateTime.now(),
      userId: tenant.userId,
    );

    // Save payment (automatically recalculates bill status & dues in Firestore transaction)
    await _repository.addTenantPayment(payment);

    if (mounted) {
      context.read<TenantDetailBloc>().add(
        LoadTenantDetailsEvent(tenantId: widget.tenantId),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Record Payment'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter Transaction Details',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: LedgerlyColors.gold,
                ),
              ),
              const SizedBox(height: 16),
              BlocBuilder<TenantDetailBloc, TenantDetailState>(
                builder: (context, detailState) {
                  final bill = detailState.bills.firstWhere(
                    (b) => b.id == widget.billId,
                  );

                  return Column(
                    children: [
                      TextFormField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Payment Amount (Max: ₹${bill.total.toStringAsFixed(0)})',
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'Required';
                          final amt = double.tryParse(val);
                          if (amt == null || amt <= 0) return 'Enter valid positive amount';
                          if (amt > bill.total) return 'Cannot exceed outstanding balance';
                          return null;
                        },
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _modeController.text,
                dropdownColor: context.theme.cardColor,
                decoration: const InputDecoration(labelText: 'Payment Method'),
                items: _modes.map((mode) => DropdownMenuItem(value: mode, child: Text(mode))).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _modeController.text = val);
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _transactionIdController,
                decoration: const InputDecoration(labelText: 'Transaction / Reference ID'),
                validator: (val) => (val == null || val.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              _buildDatePicker(),
              const SizedBox(height: 32),

              _isLoading
                  ? const Center(child: CircularProgressIndicator(color: LedgerlyColors.gold))
                  : SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: LedgerlyColors.gold,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _addPayment,
                        child: const Text('Record Payment', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _paymentDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (date != null) {
          setState(() => _paymentDate = date);
        }
      },
      child: InputDecorator(
        decoration: const InputDecoration(labelText: 'Transaction Date'),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${_paymentDate.day}/${_paymentDate.month}/${_paymentDate.year}'),
            const Icon(Icons.calendar_today, size: 18, color: LedgerlyColors.inkSoftLight),
          ],
        ),
      ),
    );
  }
}
