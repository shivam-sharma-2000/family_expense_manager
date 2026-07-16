import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:fpdart/fpdart.dart' as fp;
import '../../../../core/di/injection_container.dart';
import '../../../../core/extensions/theme_extension.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/tenant_entity.dart';
import '../../domain/entities/electricity_reading_entity.dart';
import '../../domain/repositories/tenant_repository.dart';

class ElectricityScreen extends StatefulWidget {
  const ElectricityScreen({super.key});

  @override
  State<ElectricityScreen> createState() => _ElectricityScreenState();
}

class _ElectricityScreenState extends State<ElectricityScreen> {
  final _repository = sl<TenantRepository>();

  void _showUpdateReadingDialog(TenantEntity tenant, ElectricityReadingEntity? reading) {
    final formKey = GlobalKey<FormState>();
    final currentReadingController = TextEditingController(text: reading?.currentReading.toString() ?? '');
    final rateController = TextEditingController(text: reading?.ratePerUnit.toString() ?? '10.0');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Update Reading - ${tenant.name}'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text('Previous Reading'),
                  trailing: Text(
                    (reading?.currentReading ?? 0.0).toStringAsFixed(1),
                    style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: currentReadingController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'New Current Reading'),
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Required';
                    final curr = double.tryParse(val);
                    if (curr == null) return 'Enter a valid number';
                    final prev = reading?.currentReading ?? 0.0;
                    if (curr < prev) return 'Must be greater than or equal to previous ($prev)';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: rateController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Rate per Unit (₹)'),
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Required';
                    if (double.tryParse(val) == null) return 'Enter valid rate';
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: LedgerlyColors.inkSoftLight)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: LedgerlyColors.gold,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;

                final prev = reading?.currentReading ?? 0.0;
                final curr = double.parse(currentReadingController.text);
                final rate = double.parse(rateController.text);
                final units = curr - prev;
                final charge = units * rate;

                final newHistory = [
                  ...?reading?.history,
                  ElectricityHistoryEntry(
                    date: DateTime.now(),
                    previousReading: prev,
                    currentReading: curr,
                    unitsUsed: units,
                    ratePerUnit: rate,
                    charge: charge,
                  ),
                ];

                final updatedReading = ElectricityReadingEntity(
                  tenantId: tenant.id,
                  propertyId: tenant.propertyId,
                  previousReading: prev,
                  currentReading: curr,
                  ratePerUnit: rate,
                  unitsUsed: units,
                  currentCharge: charge,
                  lastUpdated: DateTime.now(),
                  history: newHistory,
                );

                await _repository.updateElectricityReading(updatedReading);

                // Update tenant's current reading reference as well
                final updatedTenant = tenant.copyWith(
                  // previousReading in tenant corresponds to currentReading of electricity reading
                  createdAt: tenant.createdAt,
                  updatedAt: DateTime.now(),
                );
                // Also save update
                await _repository.updateTenant(updatedTenant);

                if (mounted) Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showHistoryDialog(TenantEntity tenant, ElectricityReadingEntity? reading) {
    showDialog(
      context: context,
      builder: (context) {
        final history = reading?.history ?? [];
        return AlertDialog(
          title: Text('Reading History - ${tenant.name}'),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: history.isEmpty
                ? const Center(child: Text('No reading history found.'))
                : ListView.builder(
                    itemCount: history.length,
                    itemBuilder: (context, index) {
                      final entry = history[history.length - 1 - index]; // Latest first
                      final dateStr = DateFormat('dd MMM yyyy, hh:mm a').format(entry.date);
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(dateStr, style: const TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Prev: ${entry.previousReading.toStringAsFixed(1)}'),
                                  Text('Curr: ${entry.currentReading.toStringAsFixed(1)}'),
                                ],
                              ),
                              const Divider(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Units: ${entry.unitsUsed.toStringAsFixed(1)} x ₹${entry.ratePerUnit.toStringAsFixed(1)}'),
                                  Text(
                                    '₹${entry.charge.toStringAsFixed(1)}',
                                    style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.bold, color: LedgerlyColors.gold),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Electricity Board'),
      ),
      body: StreamBuilder(
        stream: _repository.getTenants(),
        builder: (context, tenantSnapshot) {
          if (tenantSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!tenantSnapshot.hasData) {
            return const Center(child: Text('No active tenants found.'));
          }

          final tenantsEither = tenantSnapshot.data as fp.Either<dynamic, List<TenantEntity>>;
          return tenantsEither.fold(
            (fail) => const Center(child: Text('Error loading tenants.')),
            (tenants) {
              final activeTenants = tenants.where((t) => t.status == 'Active').toList();

              if (activeTenants.isEmpty) {
                return const Center(child: Text('No active tenants to display.'));
              }

              return StreamBuilder(
                stream: _repository.getElectricityReadings(),
                builder: (context, readingsSnapshot) {
                  if (readingsSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final readingsMap = <String, ElectricityReadingEntity>{};
                  if (readingsSnapshot.hasData) {
                    final readingsEither = readingsSnapshot.data as fp.Either<dynamic, List<ElectricityReadingEntity>>;
                    readingsEither.fold(
                      (fail) {},
                      (readings) {
                        for (var r in readings) {
                          readingsMap[r.tenantId] = r;
                        }
                      },
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: activeTenants.length,
                    itemBuilder: (context, index) {
                      final tenant = activeTenants[index];
                      final reading = readingsMap[tenant.id];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    tenant.name,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    'Room ${tenant.roomNumber}',
                                    style: const TextStyle(color: LedgerlyColors.inkSoftLight),
                                  ),
                                ],
                              ),
                              const Divider(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Previous', style: TextStyle(fontSize: 12, color: LedgerlyColors.inkFaintLight)),
                                      Text(
                                        (reading?.previousReading ?? 0.0).toStringAsFixed(1),
                                        style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.w600, fontSize: 16),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Current', style: TextStyle(fontSize: 12, color: LedgerlyColors.inkFaintLight)),
                                      Text(
                                        (reading?.currentReading ?? 0.0).toStringAsFixed(1),
                                        style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.w600, fontSize: 16),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Units', style: TextStyle(fontSize: 12, color: LedgerlyColors.inkFaintLight)),
                                      Text(
                                        (reading?.unitsUsed ?? 0.0).toStringAsFixed(1),
                                        style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.w600, fontSize: 16, color: LedgerlyColors.gold),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      const Text('Charge', style: TextStyle(fontSize: 12, color: LedgerlyColors.inkFaintLight)),
                                      Text(
                                        '₹${(reading?.currentCharge ?? 0.0).toStringAsFixed(1)}',
                                        style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.bold, fontSize: 16, color: LedgerlyColors.teal),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    onPressed: () => _showHistoryDialog(tenant, reading),
                                    icon: const HugeIcon(icon: HugeIcons.strokeRoundedClock01, size: 16, color: LedgerlyColors.inkSoftLight),
                                    label: const Text('History', style: TextStyle(color: LedgerlyColors.inkSoftLight)),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: LedgerlyColors.gold,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    onPressed: () => _showUpdateReadingDialog(tenant, reading),
                                    icon: const HugeIcon(icon: HugeIcons.strokeRoundedEnergy, size: 16, color: Colors.white),
                                    label: const Text('Update Reading'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
