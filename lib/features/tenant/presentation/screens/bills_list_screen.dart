import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:fpdart/fpdart.dart' as fp;
import '../../../../core/di/injection_container.dart';
import '../../../../core/extensions/theme_extension.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/tenant_bill_entity.dart';
import '../../domain/repositories/tenant_repository.dart';
import '../widgets/share_bill_sheet.dart';

class BillsListScreen extends StatefulWidget {
  const BillsListScreen({super.key});

  @override
  State<BillsListScreen> createState() => _BillsListScreenState();
}

class _BillsListScreenState extends State<BillsListScreen> {
  final _repository = sl<TenantRepository>();
  String _searchQuery = '';
  String _statusFilter = 'All'; // All | Paid | Unpaid | Partially Paid
  String _selectedMonth = 'All'; // All | YYYY-MM
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _deleteBill(TenantBillEntity bill) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Bill'),
        content: Text('Are you sure you want to delete bill ${bill.billNumber}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: LedgerlyColors.coral),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _repository.deleteTenantBill(bill.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Invoices & Bills'),
      ),
      body: Column(
        children: [
          // Search & Filters
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by tenant name or room...',
                prefixIcon: const Icon(Icons.search, color: LedgerlyColors.inkSoftLight),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
              onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
            ),
          ),
          // Filter Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  DropdownButton<String>(
                    value: _statusFilter,
                    dropdownColor: context.theme.cardColor,
                    style: TextStyle(color: context.theme.colorScheme.onSurface),
                    items: ['All', 'Paid', 'Unpaid', 'Partially Paid'].map((status) {
                      return DropdownMenuItem(value: status, child: Text('Status: $status'));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _statusFilter = val);
                    },
                  ),
                  const SizedBox(width: 16),
                  StreamBuilder(
                    stream: _repository.getAllBills(),
                    builder: (context, snapshot) {
                      final months = {'All'};
                      if (snapshot.hasData) {
                        final either = snapshot.data as fp.Either<dynamic, List<TenantBillEntity>>;
                        either.fold((_) {}, (bills) {
                          for (var b in bills) {
                            months.add(b.month);
                          }
                        });
                      }
                      return DropdownButton<String>(
                        value: _selectedMonth,
                        dropdownColor: context.theme.cardColor,
                        style: TextStyle(color: context.theme.colorScheme.onSurface),
                        items: months.map((m) {
                          return DropdownMenuItem(value: m, child: Text(m == 'All' ? 'Month: All' : 'Month: $m'));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedMonth = val);
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          // List View
          Expanded(
            child: StreamBuilder(
              stream: _repository.getAllBills(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData) {
                  return const Center(child: Text('No bills found.'));
                }

                final either = snapshot.data as fp.Either<dynamic, List<TenantBillEntity>>;
                return either.fold(
                  (fail) => const Center(child: Text('Error loading bills.')),
                  (bills) {
                    // Apply filters
                    var filtered = bills.where((b) {
                      final matchesSearch = b.tenantName.toLowerCase().contains(_searchQuery) ||
                          b.roomNumber.toLowerCase().contains(_searchQuery) ||
                          b.billNumber.toLowerCase().contains(_searchQuery);
                      final matchesStatus = _statusFilter == 'All' || b.status == _statusFilter;
                      final matchesMonth = _selectedMonth == 'All' || b.month == _selectedMonth;
                      return matchesSearch && matchesStatus && matchesMonth;
                    }).toList();

                    // Sort latest first
                    filtered.sort((a, b) => b.createdDate.compareTo(a.createdDate));

                    if (filtered.isEmpty) {
                      return const Center(child: Text('No matching bills.'));
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final bill = filtered[index];
                        final dateStr = DateFormat('dd MMM yyyy').format(bill.createdDate);
                        Color statusColor;
                        Color statusBg;
                        switch (bill.status) {
                          case 'Paid':
                            statusColor = LedgerlyColors.teal;
                            statusBg = LedgerlyColors.tealSoft;
                            break;
                          case 'Partially Paid':
                            statusColor = LedgerlyColors.amber;
                            statusBg = LedgerlyColors.amberSoft;
                            break;
                          default:
                            statusColor = LedgerlyColors.coral;
                            statusBg = LedgerlyColors.coralSoft;
                        }

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onTap: () {
                              _showInvoicePreview(context, bill);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        bill.billNumber,
                                        style: GoogleFonts.jetBrainsMono(
                                          fontWeight: FontWeight.bold,
                                          color: LedgerlyColors.navy900,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: statusBg,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          bill.status,
                                          style: TextStyle(
                                            color: statusColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    bill.tenantName,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Room: ${bill.roomNumber} | Month: ${bill.month}',
                                        style: const TextStyle(color: LedgerlyColors.inkSoftLight),
                                      ),
                                      Text(
                                        '₹${bill.total.toStringAsFixed(0)}',
                                        style: GoogleFonts.jetBrainsMono(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: LedgerlyColors.navy950,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Divider(height: 24),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Due: $dateStr', style: const TextStyle(fontSize: 12)),
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: const HugeIcon(icon: HugeIcons.strokeRoundedShare01, size: 20, color: LedgerlyColors.gold),
                                            onPressed: () {
                                              showModalBottomSheet(
                                                context: context,
                                                shape: const RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.only(
                                                    topLeft: Radius.circular(18),
                                                    topRight: Radius.circular(18),
                                                  ),
                                                ),
                                                builder: (context) => ShareBillSheet(bill: bill),
                                              );
                                            },
                                          ),
                                          IconButton(
                                            icon: const HugeIcon(icon: HugeIcons.strokeRoundedDelete02, size: 20, color: LedgerlyColors.coral),
                                            onPressed: () => _deleteBill(bill),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showInvoicePreview(BuildContext context, TenantBillEntity bill) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Invoice',
      pageBuilder: (context, _, __) {
        return InvoicePreviewDialog(bill: bill);
      },
    );
  }
}

class InvoicePreviewDialog extends StatelessWidget {
  final TenantBillEntity bill;

  const InvoicePreviewDialog({super.key, required this.bill});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    switch (bill.status) {
      case 'Paid':
        statusColor = LedgerlyColors.teal;
        break;
      case 'Partially Paid':
        statusColor = LedgerlyColors.amber;
        break;
      default:
        statusColor = LedgerlyColors.coral;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Invoice Details', style: TextStyle(color: LedgerlyColors.navy900)),
        leading: IconButton(
          icon: const Icon(Icons.close, color: LedgerlyColors.navy900),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: const BorderSide(color: LedgerlyColors.borderLight, width: 2),
            ),
            child: Column(
              children: [
                // Dashed gold top border
                Container(
                  height: 6,
                  decoration: const BoxDecoration(
                    color: LedgerlyColors.gold,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header & Rotated stamp
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('LEDGERLY', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: LedgerlyColors.navy900, fontSize: 24)),
                              Text(bill.billNumber, style: GoogleFonts.jetBrainsMono(color: LedgerlyColors.inkSoftLight)),
                            ],
                          ),
                          // Rotated Stamp
                          Transform.rotate(
                            angle: -0.15,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                border: Border.all(color: statusColor, width: 3),
                              ),
                              child: Text(
                                bill.status.toUpperCase(),
                                style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      // Details
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('BILL TO:', style: TextStyle(color: LedgerlyColors.inkFaintLight, fontSize: 12, fontWeight: FontWeight.bold)),
                              Text(bill.tenantName, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 16)),
                              Text('Room ${bill.roomNumber}', style: const TextStyle(color: LedgerlyColors.inkSoftLight)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('DATE:', style: TextStyle(color: LedgerlyColors.inkFaintLight, fontSize: 12, fontWeight: FontWeight.bold)),
                              Text(DateFormat('dd MMM yyyy').format(bill.createdDate)),
                              const SizedBox(height: 6),
                              const Text('DUE:', style: TextStyle(color: LedgerlyColors.inkFaintLight, fontSize: 12, fontWeight: FontWeight.bold)),
                              Text(DateFormat('dd MMM yyyy').format(bill.dueDate)),
                            ],
                          ),
                        ],
                      ),
                      const Divider(height: 40),
                      // Line items table
                      Table(
                        columnWidths: const {
                          0: FlexColumnWidth(3),
                          1: FlexColumnWidth(1),
                        },
                        children: [
                          const TableRow(
                            children: [
                              TableCell(child: Text('DESCRIPTION', style: TextStyle(color: LedgerlyColors.inkFaintLight, fontWeight: FontWeight.bold, fontSize: 12))),
                              TableCell(child: Align(alignment: Alignment.centerRight, child: Text('AMOUNT', style: TextStyle(color: LedgerlyColors.inkFaintLight, fontWeight: FontWeight.bold, fontSize: 12)))),
                            ],
                          ),
                          _buildInvoiceRow('Rent', bill.rent),
                          if (bill.electricity > 0)
                            _buildInvoiceRow('Electricity (${bill.electricityUnits.toStringAsFixed(1)} Units)', bill.electricity),
                          if (bill.maintenance > 0)
                            _buildInvoiceRow('Maintenance', bill.maintenance),
                          if (bill.other > 0)
                            _buildInvoiceRow('Other', bill.other),
                          if (bill.previousDue > 0)
                            _buildInvoiceRow('Previous Carry-over Due', bill.previousDue),
                          if (bill.advanceAdjustment > 0)
                            _buildInvoiceRow('Advance Adjustment', -bill.advanceAdjustment),
                          if (bill.discount > 0)
                            _buildInvoiceRow('Discount', -bill.discount),
                        ],
                      ),
                      const Divider(height: 40),
                      // Total
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('TOTAL DUE', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 18)),
                          Text(
                            '₹${bill.total.toStringAsFixed(2)}',
                            style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.bold, fontSize: 22, color: LedgerlyColors.gold),
                          ),
                        ],
                      ),
                      if (bill.notes.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        const Text('NOTES:', style: TextStyle(color: LedgerlyColors.inkFaintLight, fontSize: 12, fontWeight: FontWeight.bold)),
                        Text(bill.notes, style: const TextStyle(fontStyle: FontStyle.italic)),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(18),
                        topRight: Radius.circular(18),
                      ),
                    ),
                    builder: (context) => ShareBillSheet(bill: bill),
                  );
                },
                child: const Text('Share Invoice'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  TableRow _buildInvoiceRow(String desc, double amt) {
    return TableRow(
      children: [
        TableCell(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(desc, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
        ),
        TableCell(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                '₹${amt.toStringAsFixed(2)}',
                style: GoogleFonts.jetBrainsMono(
                  fontWeight: FontWeight.bold,
                  color: amt < 0 ? LedgerlyColors.teal : LedgerlyColors.inkLight,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
