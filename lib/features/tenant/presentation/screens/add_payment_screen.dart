import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/di/injection_container.dart';
import '../../domain/entities/tenant_payment_entity.dart';
import '../../domain/usecases/add_tenant_payment.dart';
import '../../domain/usecases/update_tenant_bill.dart';
import '../bloc/tenant_bloc.dart';
import '../bloc/tenant_detail_bloc.dart';

class AddPaymentScreen extends StatefulWidget {
  final String tenantId;
  final String billId;
  const AddPaymentScreen({super.key, required this.tenantId, required this.billId});

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
    final tenant = (tenantBloc.state as TenantLoaded).tenants.firstWhere((t) => t.id == widget.tenantId);

    final payment = TenantPaymentEntity(
      id: const Uuid().v4(),
      tenantId: widget.tenantId,
      billId: widget.billId,
      amount: double.tryParse(_amountController.text) ?? 0.0,
      date: _paymentDate,
      mode: _modeController.text,
      notes: _referenceController.text.trim().isEmpty ? null : _referenceController.text.trim(),
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

    if (mounted) context.read<TenantDetailBloc>().add(LoadTenantDetailsEvent(tenantId: widget.tenantId));

    if (!mounted) return;
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Add Payment', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const HugeIcon(size: 18.0,  icon: HugeIcons.strokeRoundedArrowLeft01, color: Colors.white, ),
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
              const Text('Payment Details', style: TextStyle(color: Colors.amber, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              
              BlocBuilder<TenantDetailBloc, TenantDetailState>(
                builder: (context, detailState) {
                  final bill = detailState.bills.firstWhere((b) => b.id == widget.billId);
                  
                  return _buildTextField(
                    controller: _amountController,
                    label: 'Amount (Max: ₹${bill.pendingAmount})',
                    icon: HugeIcons.strokeRoundedMoney04,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Required';
                      final amount = double.tryParse(val) ?? 0.0;
                      if (amount <= 0) return 'Enter valid amount';
                      if (amount > bill.pendingAmount) return 'Amount cannot exceed pending due (₹${bill.pendingAmount})';
                      return null;
                    },
                  );
                },
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
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.dark(
                            primary: Colors.amber,
                            onPrimary: Colors.black,
                            surface: Color(0xFF1A1A1A),
                            onSurface: Colors.white,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (date != null) setState(() => _paymentDate = date);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      const HugeIcon(size: 18.0,  icon: HugeIcons.strokeRoundedCalendar01, color: Colors.white54, ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Payment Date', style: TextStyle(color: Colors.white54, fontSize: 12)),
                            Text('${_paymentDate.day}/${_paymentDate.month}/${_paymentDate.year}', style: const TextStyle(color: Colors.white, fontSize: 16)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _modeController.text,
                dropdownColor: const Color(0xFF1A1A1A),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Payment Mode',
                  labelStyle: const TextStyle(color: Colors.white54),
                  prefixIcon: const HugeIcon(size: 18.0,  icon: HugeIcons.strokeRoundedWallet01, color: Colors.white54, ),
                  filled: true,
                  fillColor: const Color(0xFF1A1A1A),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                items: _modes.map((mode) => DropdownMenuItem(value: mode, child: Text(mode))).toList(),
                onChanged: (val) { if (val != null) setState(() => _modeController.text = val); },
              ),

              const SizedBox(height: 16),
              _buildTextField(
                controller: _referenceController,
                label: 'Reference Number (Optional)',
                icon: HugeIcons.strokeRoundedNote01,
              ),

              const SizedBox(height: 32),
              _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.amber))
                  : SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _addPayment,
                        child: const Text('Record Payment', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white54),
          prefixIcon: HugeIcon(size: 18.0,  icon: icon, color: Colors.white54, ),
          filled: true,
          fillColor: const Color(0xFF1A1A1A),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.amber)),
        ),
        validator: validator ?? (val) {
          if (label.contains('Optional')) return null;
          return (val == null || val.isEmpty) ? 'Required' : null;
        },
      ),
    );
  }
}
