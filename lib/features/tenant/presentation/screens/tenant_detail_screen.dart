import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../core/routes/my_app_router_const.dart';
import '../bloc/tenant_bloc.dart';
import '../bloc/tenant_detail_bloc.dart';
import '../../domain/entities/tenant_bill_entity.dart';
import '../../domain/entities/tenant_payment_entity.dart';

class TenantDetailScreen extends StatefulWidget {
  final String tenantId;

  const TenantDetailScreen({super.key, required this.tenantId});

  @override
  State<TenantDetailScreen> createState() => _TenantDetailScreenState();
}

class _TenantDetailScreenState extends State<TenantDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<TenantDetailBloc>().add(LoadTenantDetailsEvent(tenantId: widget.tenantId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Tenant Details', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const HugeIcon(size: 18.0,  icon: HugeIcons.strokeRoundedArrowLeft01, color: Colors.white, ),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const HugeIcon(size: 18.0,  icon: HugeIcons.strokeRoundedEdit01, color: Colors.amber, ),
            onPressed: () {
              context.push('${MyAppRouteConst.addEditTenant}/${widget.tenantId}');
            },
          )
        ],
      ),
      body: BlocBuilder<TenantBloc, TenantState>(
        builder: (context, tenantState) {
          if (tenantState is! TenantLoaded) {
            return const Center(child: CircularProgressIndicator(color: Colors.amber));
          }

          final tenant = tenantState.tenants.firstWhere((t) => t.id == widget.tenantId);

          return BlocBuilder<TenantDetailBloc, TenantDetailState>(
            builder: (context, detailState) {
              if (detailState.isLoading) {
                return const Center(child: CircularProgressIndicator(color: Colors.amber));
              }

              final combinedList = [
                ...detailState.bills.map((b) => {'isBill': true, 'data': b, 'date': b.billDate}),
                ...detailState.payments.map((p) => {'isBill': false, 'data': p, 'date': p.date}),
              ];
              combinedList.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Header
                    Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.amber.withAlpha(25),
                            child: Text(
                              tenant.name.substring(0, 1).toUpperCase(),
                              style: const TextStyle(fontSize: 32, color: Colors.amber, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(tenant.name, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                          Text('Room ${tenant.roomNumber} | ₹${tenant.rent.toStringAsFixed(0)}/mo', style: const TextStyle(color: Colors.white54, fontSize: 16)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Actions
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A1A1A),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () => context.push('${MyAppRouteConst.generateBill}/${widget.tenantId}'),
                        icon: const HugeIcon(size: 18.0,  icon: HugeIcons.strokeRoundedInvoice01, color: Colors.blue, ),
                        label: const Text('Generate New Bill'),
                      ),
                    ),

                    const SizedBox(height: 32),
                    const Text('Transaction History', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    if (combinedList.isEmpty)
                      const Text('No transactions recorded yet.', style: TextStyle(color: Colors.white54))
                    else
                      ...combinedList.map((item) {
                        final isBill = item['isBill'] as bool;
                        if (isBill) {
                          final bill = item['data'] as TenantBillEntity;
                          final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                          final monthStr = months[bill.month - 1];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(12)),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: Colors.blue.withAlpha(25),
                                      child: const HugeIcon(size: 18.0,  icon: HugeIcons.strokeRoundedInvoice01, color: Colors.blue, ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Bill Generated ($monthStr ${bill.year})', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                          Text('Rent: ₹${bill.rentAmount} | Elec: ₹${bill.electricityAmount}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                                          if (bill.previousDue > 0)
                                            Text('Prev Due: ₹${bill.previousDue}', style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text('₹${bill.totalAmount}', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 16)),
                                        if (bill.pendingAmount > 0)
                                          Text('Due: ₹${bill.pendingAmount}', style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold))
                                        else
                                          const Text('Paid', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ],
                                ),
                                if (bill.pendingAmount > 0)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 12),
                                    child: SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.amber,
                                          foregroundColor: Colors.black,
                                        ),
                                        onPressed: () {
                                          context.push('${MyAppRouteConst.addPayment}/${widget.tenantId}', extra: bill.id);
                                        },
                                        child: Text('Pay Due (₹${bill.pendingAmount})'),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        } else {
                          final payment = item['data'] as TenantPaymentEntity;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(12)),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.green.withAlpha(25),
                                  child: const HugeIcon(size: 18.0,  icon: HugeIcons.strokeRoundedMoney04, color: Colors.green, ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Payment Received', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                      Text('${payment.date.day}/${payment.date.month}/${payment.date.year} • ${payment.mode}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                                    ],
                                  ),
                                ),
                                Text('+₹${payment.amount}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16)),
                              ],
                            ),
                          );
                        }
                      }),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
