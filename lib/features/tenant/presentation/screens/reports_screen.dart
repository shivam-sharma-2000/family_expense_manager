import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:fpdart/fpdart.dart' as fp;
import '../../../../core/di/injection_container.dart';
import '../../../../core/extensions/theme_extension.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/tenant_bill_entity.dart';
import '../../domain/entities/tenant_entity.dart';
import '../../domain/repositories/tenant_repository.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final _repository = sl<TenantRepository>();
  String _activeTab = 'Income'; // Income | Overdues | Electricity

  Future<void> _exportToCSV(List<dynamic> headers, List<List<dynamic>> rows, String filename) async {
    final csvContent = StringBuffer();
    // Headers
    csvContent.writeln(headers.map((h) => '"$h"').join(','));
    // Rows
    for (var row in rows) {
      csvContent.writeln(row.map((val) => '"$val"').join(','));
    }

    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$filename.csv');
      await file.writeAsString(csvContent.toString());
      await Share.shareXFiles([XFile(file.path)], subject: 'Export $filename');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to export CSV')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Reports & Analytics'),
      ),
      body: StreamBuilder(
        stream: _repository.getAllBills(),
        builder: (context, billsSnapshot) {
          if (billsSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!billsSnapshot.hasData) {
            return const Center(child: Text('No reports data.'));
          }

          final billsEither = billsSnapshot.data as fp.Either<dynamic, List<TenantBillEntity>>;
          return billsEither.fold(
            (fail) => const Center(child: Text('Error loading bills.')),
            (bills) {
              return StreamBuilder(
                stream: _repository.getTenants(),
                builder: (context, tenantsSnapshot) {
                  var tenants = <TenantEntity>[];
                  if (tenantsSnapshot.hasData) {
                    final tenantsEither = tenantsSnapshot.data as fp.Either<dynamic, List<TenantEntity>>;
                    tenantsEither.fold((_) {}, (list) => tenants = list);
                  }

                  // 1. Tabbed Content
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            _buildTabChip('Income'),
                            const SizedBox(width: 8),
                            _buildTabChip('Overdues'),
                            const SizedBox(width: 8),
                            _buildTabChip('Electricity'),
                          ],
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _buildReportContent(bills, tenants),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildTabChip(String tab) {
    final isSelected = _activeTab == tab;
    return ChoiceChip(
      label: Text(tab),
      selected: isSelected,
      selectedColor: LedgerlyColors.goldSoft,
      labelStyle: TextStyle(
        color: isSelected ? LedgerlyColors.gold : LedgerlyColors.inkSoftLight,
        fontWeight: FontWeight.bold,
      ),
      onSelected: (val) {
        if (val) setState(() => _activeTab = tab);
      },
    );
  }

  Widget _buildReportContent(List<TenantBillEntity> bills, List<TenantEntity> tenants) {
    if (_activeTab == 'Income') {
      // Aggregate Income by Month
      final incomeMap = <String, double>{};
      for (var b in bills) {
        if (b.status == 'Paid') {
          incomeMap[b.month] = (incomeMap[b.month] ?? 0.0) + b.total;
        }
      }

      final sortedMonths = incomeMap.keys.toList()..sort((a, b) => b.compareTo(a));

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Monthly Rent Income', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 18)),
              IconButton(
                icon: const HugeIcon(icon: HugeIcons.strokeRoundedDownload01, color: LedgerlyColors.gold),
                onPressed: () {
                  final rows = sortedMonths.map((m) => [m, '₹${incomeMap[m]!.toStringAsFixed(2)}']).toList();
                  _exportToCSV(['Month', 'Income (INR)'], rows, 'monthly_income_report');
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (sortedMonths.isEmpty)
            const Text('No rent collections recorded yet.')
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sortedMonths.length,
              itemBuilder: (context, index) {
                final month = sortedMonths[index];
                final amt = incomeMap[month]!;
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(month, style: const TextStyle(fontWeight: FontWeight.bold)),
                    trailing: Text(
                      '₹${amt.toStringAsFixed(0)}',
                      style: GoogleFonts.jetBrainsMono(color: LedgerlyColors.teal, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                );
              },
            ),
        ],
      );
    } else if (_activeTab == 'Overdues') {
      // Filter Unpaid Bills
      final unpaid = bills.where((b) => b.status != 'Paid').toList();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Pending Payments', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 18)),
              IconButton(
                icon: const HugeIcon(icon: HugeIcons.strokeRoundedDownload01, color: LedgerlyColors.gold),
                onPressed: () {
                  final rows = unpaid.map((b) => [b.billNumber, b.tenantName, b.roomNumber, b.month, '₹${b.total.toStringAsFixed(2)}']).toList();
                  _exportToCSV(['Bill #', 'Tenant', 'Room', 'Month', 'Overdue Amount (INR)'], rows, 'pending_payments_report');
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (unpaid.isEmpty)
            const Text('No pending balances.')
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: unpaid.length,
              itemBuilder: (context, index) {
                final bill = unpaid[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(bill.tenantName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Room ${bill.roomNumber} • Bill ${bill.billNumber} (${bill.month})'),
                    trailing: Text(
                      '₹${bill.total.toStringAsFixed(0)}',
                      style: GoogleFonts.jetBrainsMono(color: LedgerlyColors.coral, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                );
              },
            ),
        ],
      );
    } else {
      // Electricity Consumption by tenant
      final sortedBills = List<TenantBillEntity>.from(bills)
        ..sort((a, b) => b.month.compareTo(a.month));

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Electricity Consumption Log', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 18)),
              IconButton(
                icon: const HugeIcon(icon: HugeIcons.strokeRoundedDownload01, color: LedgerlyColors.gold),
                onPressed: () {
                  final rows = sortedBills.map((b) => [b.month, b.tenantName, b.roomNumber, b.electricityUnits, '₹${b.electricity.toStringAsFixed(2)}']).toList();
                  _exportToCSV(['Month', 'Tenant', 'Room', 'Units Used', 'Charged Amount (INR)'], rows, 'electricity_consumption_report');
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (sortedBills.isEmpty)
            const Text('No electricity readings recorded.')
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sortedBills.length,
              itemBuilder: (context, index) {
                final bill = sortedBills[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(bill.tenantName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Room ${bill.roomNumber} • ${bill.electricityUnits.toStringAsFixed(1)} units used'),
                    trailing: Text(
                      '₹${bill.electricity.toStringAsFixed(0)}',
                      style: GoogleFonts.jetBrainsMono(color: LedgerlyColors.navy950, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                );
              },
            ),
        ],
      );
    }
  }
}
