import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:uuid/uuid.dart';
import 'package:fpdart/fpdart.dart' as fp;
import '../../../../core/di/injection_container.dart';
import '../../../../core/extensions/theme_extension.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/tenant_bill_entity.dart';
import '../../domain/entities/electricity_reading_entity.dart';
import '../../domain/usecases/add_tenant_bill.dart';
import '../../domain/usecases/update_tenant_bill.dart';
import '../../domain/usecases/update_tenant.dart';
import '../../domain/repositories/tenant_repository.dart';
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
  final _repository = sl<TenantRepository>();

  final _rentController = TextEditingController();
  final _prevMeterController = TextEditingController();
  final _currMeterController = TextEditingController();
  final _unitRateController = TextEditingController();
  final _maintenanceController = TextEditingController();
  final _otherController = TextEditingController(text: '0');
  final _discountController = TextEditingController(text: '0');
  final _adjustmentController = TextEditingController(text: '0');
  final _notesController = TextEditingController();

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
    _loadTenantDetails();
  }

  void _loadTenantDetails() async {
    final tenantBloc = context.read<TenantBloc>();
    if (tenantBloc.state is TenantLoaded) {
      final tenant = (tenantBloc.state as TenantLoaded).tenants.firstWhere(
        (t) => t.id == widget.tenantId,
      );
      _rentController.text = tenant.rent.toString();
      _maintenanceController.text = '0'; // Default to 0, user can change
      _unitRateController.text = '10.0'; // Default to 10

      // Fetch electricity meter reading records to prefill prev meter
      _repository.getElectricityReadings().first.then((either) {
        either.fold((_) {}, (readings) {
          final reading = readings.firstWhere(
            (r) => r.tenantId == widget.tenantId,
            orElse: () => ElectricityReadingEntity(
              tenantId: widget.tenantId,
              propertyId: tenant.propertyId,
              previousReading: 0.0,
              currentReading: 0.0,
              ratePerUnit: 10.0,
              unitsUsed: 0.0,
              currentCharge: 0.0,
              lastUpdated: DateTime.now(),
              history: const [],
            ),
          );
          if (mounted) {
            setState(() {
              _prevMeterController.text = reading.currentReading.toString();
              _unitRateController.text = reading.ratePerUnit.toString();
            });
          }
        });
      });
    }
  }

  @override
  void dispose() {
    _rentController.dispose();
    _prevMeterController.dispose();
    _currMeterController.dispose();
    _unitRateController.dispose();
    _maintenanceController.dispose();
    _otherController.dispose();
    _discountController.dispose();
    _adjustmentController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _generateBill() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final tenantBloc = context.read<TenantBloc>();
    if (tenantBloc.state is! TenantLoaded) return;
    final tenant = (tenantBloc.state as TenantLoaded).tenants.firstWhere(
      (t) => t.id == widget.tenantId,
    );

    // Auto bill number compilation: BILL-YYYY-XXXX (count existing bills to generate sequential serial)
    final existingBillsEither = await _repository.getAllBills().first;
    int serial = 1;
    existingBillsEither.fold((_) {}, (list) {
      serial = list.length + 1;
    });
    final billNumber = 'BILL-${_selectedYear}-${serial.toString().padLeft(4, '0')}';

    final rent = double.tryParse(_rentController.text) ?? 0.0;
    final prev = double.tryParse(_prevMeterController.text) ?? 0.0;
    final curr = double.tryParse(_currMeterController.text) ?? 0.0;
    final rate = double.tryParse(_unitRateController.text) ?? 10.0;
    final maintenance = double.tryParse(_maintenanceController.text) ?? 0.0;
    final other = double.tryParse(_otherController.text) ?? 0.0;
    final discount = double.tryParse(_discountController.text) ?? 0.0;
    final adjustment = double.tryParse(_adjustmentController.text) ?? 0.0;

    final double consumed = curr > prev ? curr - prev : 0.0;
    final double electricityAmt = consumed * rate;

    // Fetch previous due (unpaid) balances from history to carry forward
    final detailState = context.read<TenantDetailBloc>().state;
    double previousDue = 0.0;
    TenantBillEntity? latestUnpaidBill;
    if (detailState.bills.isNotEmpty) {
      for (var b in detailState.bills) {
        if (b.status != 'Paid') {
          latestUnpaidBill = b;
          previousDue = b.total; // carry forward entire total
          break;
        }
      }
    }

    final double total = (rent + electricityAmt + maintenance + other + previousDue) - discount - adjustment;

    final monthStr = '${_selectedYear}-${_selectedMonth.toString().padLeft(2, '0')}';

    final bill = TenantBillEntity(
      id: const Uuid().v4(),
      propertyId: tenant.propertyId,
      billNumber: billNumber,
      tenantId: widget.tenantId,
      tenantName: tenant.name,
      roomNumber: tenant.roomNumber,
      month: monthStr,
      dueDate: DateTime.now().add(const Duration(days: 7)),
      createdDate: DateTime.now(),
      rent: rent,
      electricityUnits: consumed,
      electricityRate: rate,
      electricity: electricityAmt,
      maintenance: maintenance,
      other: other,
      previousDue: previousDue,
      advanceAdjustment: adjustment,
      discount: discount,
      total: total,
      status: 'Unpaid',
      notes: _notesController.text.trim(),
      pdfUrl: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      userId: tenant.userId,
    );

    // Save Bill to Firestore
    await _repository.addTenantBill(bill);

    // Clear previous bill status to Paid (since carried forward)
    if (latestUnpaidBill != null) {
      await _repository.updateTenantBill(latestUnpaidBill.copyWith(
        status: 'Paid',
        updatedAt: DateTime.now(),
      ));
    }

    // Update Electricity reading logs
    if (curr > prev) {
      final updatedReading = ElectricityReadingEntity(
        tenantId: widget.tenantId,
        propertyId: tenant.propertyId,
        previousReading: prev,
        currentReading: curr,
        ratePerUnit: rate,
        unitsUsed: consumed,
        currentCharge: electricityAmt,
        lastUpdated: DateTime.now(),
        history: [
          ElectricityHistoryEntry(
            date: DateTime.now(),
            previousReading: prev,
            currentReading: curr,
            unitsUsed: consumed,
            ratePerUnit: rate,
            charge: electricityAmt,
          ),
        ],
      );
      await _repository.updateElectricityReading(updatedReading);
    }

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
        title: const Text('Compile Bill Invoice'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: LedgerlyColors.gold))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Period',
                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 18, color: LedgerlyColors.gold),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            value: _selectedMonth,
                            dropdownColor: context.theme.cardColor,
                            decoration: const InputDecoration(labelText: 'Billing Month'),
                            items: List.generate(
                              12,
                              (index) => DropdownMenuItem(value: index + 1, child: Text(_months[index])),
                            ),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedMonth = val);
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            value: _selectedYear,
                            dropdownColor: context.theme.cardColor,
                            decoration: const InputDecoration(labelText: 'Billing Year'),
                            items: List.generate(5, (index) {
                              final yr = DateTime.now().year - 2 + index;
                              return DropdownMenuItem(value: yr, child: Text(yr.toString()));
                            }),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedYear = val);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    Text('Rent & Common Charges', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 18, color: LedgerlyColors.gold)),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _rentController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Rent Charge (₹)'),
                      validator: (val) => (val == null || val.isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _maintenanceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Maintenance Charge (₹)'),
                      validator: (val) => (val == null || val.isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _otherController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Other Miscellaneous Charges (₹)'),
                    ),
                    const SizedBox(height: 32),

                    Text('Electricity Consumption', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 18, color: LedgerlyColors.gold)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _prevMeterController,
                            readOnly: true,
                            decoration: const InputDecoration(labelText: 'Prev Meter Reading'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _currMeterController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(labelText: 'Curr Meter Reading'),
                            validator: (val) {
                              if (val == null || val.isEmpty) return 'Required';
                              final curr = double.tryParse(val);
                              final prev = double.tryParse(_prevMeterController.text) ?? 0.0;
                              if (curr == null || curr < prev) return 'Must be >= Prev';
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _unitRateController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Electricity Unit Rate (₹)'),
                      validator: (val) => (val == null || val.isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 32),

                    Text('Adjustments & Discounts', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 18, color: LedgerlyColors.gold)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _discountController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Discount Applied (₹)'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _adjustmentController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Advance Adjustment (₹)'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(labelText: 'Invoice Notes (Optional)'),
                    ),
                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: LedgerlyColors.gold,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _generateBill,
                        child: const Text('Generate Invoice', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }
}
