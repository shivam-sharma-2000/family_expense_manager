import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/extensions/theme_extension.dart';
import '../../domain/entities/tenant_payment_entity.dart';
import '../../domain/usecases/add_tenant_payment.dart';
import '../../domain/usecases/update_tenant_bill.dart';
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
  final _referenceController = TextEditingController();

  DateTime _paymentDate = DateTime.now();
  bool _isLoading = false;

  final List<String> _modes = ['Cash', 'UPI', 'Bank Transfer', 'Cheque'];

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
      tenantId: widget.tenantId,
      billId: widget.billId,
      amount: double.tryParse(_amountController.text) ?? 0.0,
      date: _paymentDate,
      mode: _modeController.text,
      notes: _referenceController.text.trim().isEmpty
          ? null
          : _referenceController.text.trim(),
      userId: tenant.userId,
      familyId: tenant.familyId,
      isSynced: false,
      isDeleted: false,
    );

    final addTenantPayment = sl<AddTenantPayment>();
    await addTenantPayment(payment);

    // Update bill
    final detailState = context.read<TenantDetailBloc>().state;
    final bill = detailState.bills.firstWhere((b) => b.id == widget.billId);

    final updateTenantBill = sl<UpdateTenantBill>();
    final updatedBill = bill.copyWith(
      paidAmount: bill.paidAmount + payment.amount,
      pendingAmount: bill.pendingAmount - payment.amount,
      isSynced: false,
    );
    await updateTenantBill(updatedBill);

    if (mounted)
      context.read<TenantDetailBloc>().add(
        LoadTenantDetailsEvent(tenantId: widget.tenantId),
      );

    if (!mounted) return;
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          'Add Payment',
          style: context.theme.textTheme.headlineMedium,
        ),
        leading: IconButton(
          icon: HugeIcon(
            icon: HugeIcons.strokeRoundedArrowLeft01,
            color: context.theme.colorScheme.onSurface,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Payment Details',
                style: TextStyle(
                  color: context.theme.colorScheme.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),
              BlocBuilder<TenantDetailBloc, TenantDetailState>(
                builder: (context, detailState) {
                  final bill = detailState.bills.firstWhere(
                    (b) => b.id == widget.billId,
                  );

                  return _buildTextField(
                    controller: _amountController,
                    label: 'Amount (Max: ₹${bill.pendingAmount})',
                    icon: HugeIcons.strokeRoundedMoney04,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Required';
                      final amount = double.tryParse(val) ?? 0.0;
                      if (amount <= 0) return 'Enter valid amount';
                      if (amount > bill.pendingAmount)
                        return 'Amount cannot exceed pending due (₹${bill.pendingAmount})';
                      return null;
                    },
                  );
                },
              ),

              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: DropdownButtonFormField<String>(
                  initialValue: _modeController.text,
                  dropdownColor: context.theme.cardColor,
                  style: TextStyle(color: context.theme.colorScheme.onSurface),
                  decoration: InputDecoration(
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedWallet01,
                        color: context.theme.colorScheme.onSurface.withValues(
                          alpha: 0.54,
                        ),
                      ),
                    ),
                    filled: true,
                    fillColor: context.theme.cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: _modes
                      .map(
                        (mode) =>
                            DropdownMenuItem(value: mode, child: Text(mode)),
                      )
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _modeController.text = val);
                  },
                ),
              ),

              const SizedBox(height: 16),
              _buildTextField(
                controller: _referenceController,
                label: 'Reference Number (Optional)',
                icon: HugeIcons.strokeRoundedNote01,
              ),


              const SizedBox(height: 16),
              GestureDetector(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _paymentDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(
                          context,
                        ).copyWith(colorScheme: context.theme.colorScheme),
                        child: child!,
                      );
                    },
                  );
                  if (date != null) setState(() => _paymentDate = date);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: context.theme.cardColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      HugeIcon(
                        icon: HugeIcons.strokeRoundedCalendar01,
                        color: context.theme.colorScheme.onSurface.withValues(
                          alpha: 0.54,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${_paymentDate.day}/${_paymentDate.month}/${_paymentDate.year}',
                          style: TextStyle(
                            color: context.theme.colorScheme.onSurface,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),
              _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: context.theme.colorScheme.primary,
                      ),
                    )
                  : SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.theme.colorScheme.primary,
                          foregroundColor: context.theme.colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _addPayment,
                        child: const Text(
                          'Record Payment',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required dynamic icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(color: context.theme.colorScheme.onSurface),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: context.theme.colorScheme.onSurface.withValues(alpha: 0.54),
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(8.0),
            child: HugeIcon(
              icon: icon,
              color: context.theme.colorScheme.onSurface.withValues(alpha: 0.54),
            ),
          ),
          filled: true,
          fillColor: context.theme.cardColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: context.theme.colorScheme.primary),
          ),
        ),
        validator:
            validator ??
            (val) {
              if (label.contains('Optional')) return null;
              return (val == null || val.isEmpty) ? 'Required' : null;
            },
      ),
    );
  }
}
