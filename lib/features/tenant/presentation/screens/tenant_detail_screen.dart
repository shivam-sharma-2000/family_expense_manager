import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:fpdart/fpdart.dart' as fp;
import '../../../../core/di/injection_container.dart';
import '../../../../core/extensions/theme_extension.dart';
import '../../../../core/routes/my_app_router_const.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/tenant_bill_entity.dart';
import '../../domain/entities/tenant_payment_entity.dart';
import '../../domain/repositories/tenant_repository.dart';
import '../bloc/tenant_bloc.dart';
import '../bloc/tenant_detail_bloc.dart';

class TenantDetailScreen extends StatefulWidget {
  final String tenantId;

  const TenantDetailScreen({super.key, required this.tenantId});

  @override
  State<TenantDetailScreen> createState() => _TenantDetailScreenState();
}

class _TenantDetailScreenState extends State<TenantDetailScreen> {
  final _repository = sl<TenantRepository>();

  @override
  void initState() {
    super.initState();
    context.read<TenantDetailBloc>().add(LoadTenantDetailsEvent(tenantId: widget.tenantId));
  }

  void _deleteTenant(BuildContext context, dynamic tenant) async {
    // Block delete if status is Active
    if (tenant.status == 'Active') {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete Blocked'),
          content: const Text('This tenant is currently Active. Please mark their status as Vacated in settings before deleting.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Tenant Ledger'),
        content: Text('Are you sure you want to delete ${tenant.name} and all historical logs? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: LedgerlyColors.coral),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete Everything', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _repository.deleteTenant(widget.tenantId);
      if (context.mounted) {
        context.read<TenantBloc>().add(LoadTenantsEvent());
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Tenant File'),
      ),
      body: BlocBuilder<TenantBloc, TenantState>(
        builder: (context, tenantState) {
          if (tenantState is! TenantLoaded) {
            return const Center(child: CircularProgressIndicator(color: LedgerlyColors.gold));
          }

          final tenant = tenantState.tenants.firstWhere(
            (t) => t.id == widget.tenantId,
            orElse: () => tenantState.tenants.first,
          );

          final isActive = tenant.status == 'Active';

          return BlocBuilder<TenantDetailBloc, TenantDetailState>(
            builder: (context, detailState) {
              if (detailState.isLoading) {
                return const Center(child: CircularProgressIndicator(color: LedgerlyColors.gold));
              }

              // Combine bills and payments for timeline view
              final timelineItems = [
                ...detailState.bills.map((b) => {'isBill': true, 'data': b, 'date': b.createdDate}),
                ...detailState.payments.map((p) => {'isBill': false, 'data': p, 'date': p.date}),
              ];
              timelineItems.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));

              return SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile card
                    Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 46,
                            backgroundColor: isActive ? LedgerlyColors.tealSoft : LedgerlyColors.surfaceAltLight,
                            backgroundImage: tenant.photoUrl.isNotEmpty ? NetworkImage(tenant.photoUrl) : null,
                            child: tenant.photoUrl.isEmpty
                                ? Text(
                                    tenant.name.substring(0, 1).toUpperCase(),
                                    style: TextStyle(
                                      color: isActive ? LedgerlyColors.teal : LedgerlyColors.inkSoftLight,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 32,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            tenant.name,
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w800,
                              fontSize: 22,
                              color: LedgerlyColors.navy950,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isActive ? LedgerlyColors.tealSoft : LedgerlyColors.surfaceAltLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              tenant.status,
                              style: TextStyle(
                                color: isActive ? LedgerlyColors.teal : LedgerlyColors.inkSoftLight,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Quick Specs
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            _buildInfoRow('Room & Floor', 'Room ${tenant.roomNumber} (${tenant.floor})', HugeIcons.strokeRoundedHouse01),
                            const Divider(),
                            _buildInfoRow('Rent / mo', '₹${tenant.rent.toStringAsFixed(0)}', HugeIcons.strokeRoundedRupee),
                            const Divider(),
                            _buildInfoRow('Phone', tenant.phone, HugeIcons.strokeRoundedCall),
                            const Divider(),
                            _buildInfoRow('Email', tenant.email, HugeIcons.strokeRoundedMailAtSign01),
                            const Divider(),
                            _buildInfoRow('ID Card', tenant.idNumber, HugeIcons.strokeRoundedLicense),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: LedgerlyColors.gold,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () => context.push('${MyAppRouteConst.generateBill}/${tenant.id}'),
                            icon: const Icon(Icons.add),
                            label: const Text('Generate Bill', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          icon: const HugeIcon(icon: HugeIcons.strokeRoundedEdit02, color: LedgerlyColors.gold),
                          onPressed: () {
                            context.push('${MyAppRouteConst.addEditTenant}/${tenant.id}');
                          },
                        ),
                        IconButton(
                          icon: const HugeIcon(icon: HugeIcons.strokeRoundedDelete02, color: LedgerlyColors.coral),
                          onPressed: () => _deleteTenant(context, tenant),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Transaction history logs
                    Text(
                      'Transaction History & Invoices',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: LedgerlyColors.navy950,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (timelineItems.isEmpty)
                      const Text('No records found.')
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: timelineItems.length,
                        itemBuilder: (context, index) {
                          final item = timelineItems[index];
                          final isBill = item['isBill'] as bool;
                          final dateStr = DateFormat('dd MMM yyyy').format(item['date'] as DateTime);

                          if (isBill) {
                            final bill = item['data'] as TenantBillEntity;
                            final isPaid = bill.status == 'Paid';
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: isPaid ? LedgerlyColors.tealSoft : LedgerlyColors.coralSoft,
                                  child: HugeIcon(
                                    icon: HugeIcons.strokeRoundedInvoice01,
                                    color: isPaid ? LedgerlyColors.teal : LedgerlyColors.coral,
                                  ),
                                ),
                                title: Text(bill.billNumber),
                                subtitle: Text('Bill generated for ${bill.month} • Due $dateStr'),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '₹${bill.total.toStringAsFixed(0)}',
                                      style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.bold, color: LedgerlyColors.navy900),
                                    ),
                                    if (!isPaid)
                                      TextButton(
                                        style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(40, 24)),
                                        onPressed: () {
                                          context.push('${MyAppRouteConst.addPayment}/${tenant.id}', extra: bill.id);
                                        },
                                        child: const Text('Pay Due', style: TextStyle(color: LedgerlyColors.gold, fontSize: 12, fontWeight: FontWeight.bold)),
                                      )
                                    else
                                      const Text('Paid', style: TextStyle(color: LedgerlyColors.teal, fontSize: 11, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            );
                          } else {
                            final payment = item['data'] as TenantPaymentEntity;
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: const CircleAvatar(
                                  backgroundColor: LedgerlyColors.tealSoft,
                                  child: HugeIcon(icon: HugeIcons.strokeRoundedWallet01, color: LedgerlyColors.teal),
                                ),
                                title: const Text('Payment Received'),
                                subtitle: Text('$dateStr • Method: ${payment.method}'),
                                trailing: Text(
                                  '+₹${payment.amount.toStringAsFixed(0)}',
                                  style: GoogleFonts.jetBrainsMono(
                                    fontWeight: FontWeight.bold,
                                    color: LedgerlyColors.teal,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            );
                          }
                        },
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String title, String value, dynamic icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          HugeIcon(icon: icon, color: LedgerlyColors.inkSoftLight, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(color: LedgerlyColors.inkSoftLight, fontSize: 14),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: LedgerlyColors.navy950, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
