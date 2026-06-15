import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/di/injection_container.dart';
import '../../domain/entities/tenant_bill_entity.dart';
import '../../domain/usecases/add_tenant_bill.dart';
import '../../domain/usecases/update_tenant_bill.dart';
import '../../domain/usecases/update_tenant.dart';
import '../bloc/tenant_bloc.dart';
import '../bloc/tenant_detail_bloc.dart';

class GenerateBillScreen extends StatefulWidget {
  final String tenantId;
  const GenerateBillScreen({super.key, required this.tenantId});

  @override
  State<GenerateBillScreen> createState() => _GenerateBillScreenState();
}

class _GenerateBillScreenState extends State<GenerateBillScreen> {
  final _formKey = GlobalKey<FormState>();
  final _prevMeterController = TextEditingController();
  final _currMeterController = TextEditingController();
  final _unitRateController = TextEditingController();
  final _maintenanceController = TextEditingController();

  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  bool _isLoading = false;

  final List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  @override
  void initState() {
    super.initState();
    final tenantBloc = context.read<TenantBloc>();
    if (tenantBloc.state is TenantLoaded) {
      final tenant = (tenantBloc.state as TenantLoaded).tenants.firstWhere((t) => t.id == widget.tenantId);
      _prevMeterController.text = tenant.previousReading.toString();
      _unitRateController.text = tenant.unitRate.toString();
      _maintenanceController.text = tenant.maintenance.toString();
    }
  }

  Future<void> _generateBill() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);

    final tenantBloc = context.read<TenantBloc>();
    if (tenantBloc.state is! TenantLoaded) return;
    final tenant = (tenantBloc.state as TenantLoaded).tenants.firstWhere((t) => t.id == widget.tenantId);

    final prev = double.tryParse(_prevMeterController.text) ?? 0;
    final curr = double.tryParse(_currMeterController.text) ?? 0;
    final rate = double.tryParse(_unitRateController.text) ?? 0;
    final maintenance = double.tryParse(_maintenanceController.text) ?? 0;

    final double consumed = curr > prev ? curr - prev : 0.0;
    final double electricityAmt = consumed * rate;
    
    final detailState = context.read<TenantDetailBloc>().state;
    TenantBillEntity? latestUnpaidBill;
    double previousDue = 0.0;
    if (detailState.bills.isNotEmpty) {
      for (var b in detailState.bills) {
        if (b.pendingAmount > 0) {
          latestUnpaidBill = b;
          previousDue = b.pendingAmount;
          break;
        }
      }
    }

    final double total = tenant.rent + maintenance + electricityAmt + previousDue;

    final bill = TenantBillEntity(
      id: const Uuid().v4(),
      tenantId: widget.tenantId,
      month: _selectedMonth,
      year: _selectedYear,
      rentAmount: tenant.rent,
      electricityUnits: consumed,
      electricityAmount: electricityAmt.toDouble(),
      maintenanceAmount: maintenance,
      previousDue: previousDue,
      paidAmount: 0.0,
      totalAmount: total,
      billDate: DateTime.now(),
      pendingAmount: total,
      userId: tenant.userId,
      familyId: tenant.familyId,
      isSynced: false,
      isDeleted: false,
    );

    final addTenantBill = sl<AddTenantBill>();
    await addTenantBill(bill);

    // If there was a previous due, update the old bill to clear its pending amount (carried forward)
    if (latestUnpaidBill != null) {
      final updateTenantBill = sl<UpdateTenantBill>();
      final updatedOldBill = latestUnpaidBill.copyWith(
        pendingAmount: 0.0,
        isSynced: false,
      );
      await updateTenantBill(updatedOldBill);
    }

    final bool needsUpdate = curr != prev || rate != tenant.unitRate || maintenance != tenant.maintenance;
    if (needsUpdate) {
      final updateTenant = sl<UpdateTenant>();
      final updatedTenant = tenant.copyWith(
        previousReading: curr,
        unitRate: rate,
        maintenance: maintenance,
        isSynced: false,
      );
      await updateTenant(updatedTenant);
      if (mounted) context.read<TenantBloc>().add(LoadTenantsEvent());
    }

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
        title: const Text('Generate Bill', style: TextStyle(color: Colors.white)),
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
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _selectedMonth,
                      dropdownColor: const Color(0xFF1A1A1A),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Month',
                        labelStyle: const TextStyle(color: Colors.white54),
                        filled: true,
                        fillColor: const Color(0xFF1A1A1A),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                      items: List.generate(12, (index) => DropdownMenuItem(value: index + 1, child: Text(_months[index]))),
                      onChanged: (val) { if (val != null) setState(() => _selectedMonth = val); },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _selectedYear,
                      dropdownColor: const Color(0xFF1A1A1A),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Year',
                        labelStyle: const TextStyle(color: Colors.white54),
                        filled: true,
                        fillColor: const Color(0xFF1A1A1A),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                      items: List.generate(10, (index) {
                        final yr = DateTime.now().year - 2 + index;
                        return DropdownMenuItem(value: yr, child: Text(yr.toString()));
                      }),
                      onChanged: (val) { if (val != null) setState(() => _selectedYear = val); },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text('Electricity Reading', style: TextStyle(color: Colors.amber, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildTextField(controller: _prevMeterController, label: 'Previous Reading', icon: HugeIcons.strokeRoundedDashboardCircle, readOnly: true),
              _buildTextField(controller: _currMeterController, label: 'Current Reading', icon: HugeIcons.strokeRoundedDashboardCircle),
              _buildTextField(controller: _unitRateController, label: 'Per Unit Rate (₹)', icon: HugeIcons.strokeRoundedMoney01),
              
              const SizedBox(height: 24),
              const Text('Other Charges', style: TextStyle(color: Colors.amber, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildTextField(controller: _maintenanceController, label: 'Maintenance (₹)', icon: HugeIcons.strokeRoundedMoney04),

              BlocBuilder<TenantDetailBloc, TenantDetailState>(
                builder: (context, detailState) {
                  double previousDue = 0.0;
                  if (detailState.bills.isNotEmpty) {
                    for (var b in detailState.bills) {
                      if (b.pendingAmount > 0) {
                        previousDue = b.pendingAmount;
                        break;
                      }
                    }
                  }

                  if (previousDue > 0) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: Colors.redAccent.withAlpha(25), borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          children: [
                            const HugeIcon(size: 18.0,  icon: HugeIcons.strokeRoundedAlert01, color: Colors.redAccent, ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Previous Due of ₹$previousDue will be carried forward and added to this bill automatically.',
                                style: const TextStyle(color: Colors.redAccent),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
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
                        onPressed: _generateBill,
                        child: const Text('Generate Bill', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
    bool readOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
        validator: (val) => (val == null || val.isEmpty) ? 'Required' : null,
      ),
    );
  }
}
