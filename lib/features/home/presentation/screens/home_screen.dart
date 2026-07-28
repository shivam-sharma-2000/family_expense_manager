import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:go_router/go_router.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import '../../../../core/extensions/theme_extension.dart';
import '../../../../core/routes/my_app_router_const.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/drawer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../tenant/domain/entities/tenant_entity.dart';
import '../../../tenant/domain/entities/room_entity.dart';
import '../../../tenant/domain/entities/tenant_bill_entity.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(LoadDashboard());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const HugeIcon(icon: HugeIcons.strokeRoundedMenu01,),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Text(
          'LEDGERLY',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: const HugeIcon(icon: HugeIcons.strokeRoundedSettings01, ),
            onPressed: () => context.push(MyAppRouteConst.settings),
          ),
        ],
      ),
      drawer: const HomeDrawer(),
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator(color: LedgerlyColors.gold));
          }

          if (state.error != null) {
            return Center(child: Text('Error: ${state.error}'));
          }

          return _buildDashboard(state.tenants, state.rooms, state.bills);
        },
      ),
    );
  }

  Widget _buildDashboard(List<TenantEntity> tenants, List<RoomEntity> rooms, List<TenantBillEntity> bills) {
    // 1. Stats Computations
    final totalTenants = tenants.where((t) => t.status == 'Active').length;
    final occupiedRooms = rooms.where((r) => r.status == 'Occupied').length;
    final vacantRooms = rooms.where((r) => r.status == 'Vacant').length;

    // Monthly Rent Collected (this month)
    final currentMonthStr = DateFormat('yyyy-MM').format(DateTime.now());
    final monthlyRentCollected = bills
        .where((b) => b.month == currentMonthStr && b.status == 'Paid')
        .fold(0.0, (sum, b) => sum + b.rent);

    // Pending Bills count
    final pendingBills = bills.where((b) => b.status != 'Paid').length;

    // Electricity Charges (total collected or total generated this month)
    final electricityCharges = bills
        .where((b) => b.month == currentMonthStr)
        .fold(0.0, (sum, b) => sum + b.electricity);

    // 2. Reminders & Alerts
    final now = DateTime.now();
    final billReminders = bills.where((b) {
      if (b.status == 'Paid') return false;
      final diff = b.dueDate.difference(now).inDays;
      return diff <= 5; // Due within 5 days or overdue
    }).toList();

    final leaseReminders = tenants.where((t) {
      if (t.status != 'Active') return false;
      final diff = t.agreementEndDate.difference(now).inDays;
      return diff >= 0 && diff <= 30; // Expiring within 30 days
    }).toList();

    return RefreshIndicator(
      onRefresh: () async {
        context.read<HomeBloc>().add(LoadDashboard());
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Header
            Text(
              'Property Dashboard',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w800,
                fontSize: 24,
                color: LedgerlyColors.navy950,
              ),
            ),
            Text(
              'Real-time overview of your estate ledger',
              style: GoogleFonts.inter(color: LedgerlyColors.inkSoftLight),
            ),
            const SizedBox(height: 24),

            // 6 Stat Cards Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.3,
              children: [
                _buildStatCard('Total Tenants', '$totalTenants', LedgerlyColors.gold, HugeIcons.strokeRoundedUserGroup),
                _buildStatCard('Occupied Rooms', '$occupiedRooms', LedgerlyColors.teal, HugeIcons.strokeRoundedHouse01),
                _buildStatCard('Vacant Rooms', '$vacantRooms', LedgerlyColors.inkSoftLight, HugeIcons.strokeRoundedHouse02),
                _buildStatCard('Rent Collected', '₹${monthlyRentCollected.toStringAsFixed(0)}', LedgerlyColors.teal, HugeIcons.strokeRoundedRupee),
                _buildStatCard('Pending Bills', '$pendingBills', LedgerlyColors.coral, HugeIcons.strokeRoundedInvoice01),
                _buildStatCard('Elec Charges', '₹${electricityCharges.toStringAsFixed(0)}', LedgerlyColors.amber, HugeIcons.strokeRoundedEnergy),
              ],
            ),
            const SizedBox(height: 32),

            // Charts Section
            Text(
              'Analytics & Trends',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 18, color: LedgerlyColors.navy950),
            ),
            const SizedBox(height: 16),
            _buildCharts(bills, rooms),
            const SizedBox(height: 32),

            // Reminders Section
            Text(
              'Reminders & Alerts',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 18, color: LedgerlyColors.navy950),
            ),
            const SizedBox(height: 12),
            _buildReminders(billReminders, leaseReminders),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color, dynamic icon) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: LedgerlyColors.borderLight),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F10233B),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            color: color,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: color.withValues(alpha: 0.1),
                    child: HugeIcon(
                      icon: icon,
                      color: color,
                      size: 16,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    value,
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: LedgerlyColors.navy950,
                    ),
                  ),
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: LedgerlyColors.inkSoftLight,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCharts(List<TenantBillEntity> bills, List<RoomEntity> rooms) {
    // 1. Rent Collection Bar Chart (last 6 months)
    final rentMap = <String, double>{};
    for (var b in bills) {
      if (b.status == 'Paid') {
        rentMap[b.month] = (rentMap[b.month] ?? 0.0) + b.rent;
      }
    }
    final sortedMonths = rentMap.keys.toList()..sort();
    final barData = sortedMonths.skip(sortedMonths.length > 6 ? sortedMonths.length - 6 : 0).map((m) {
      return _ChartData(m, rentMap[m]!);
    }).toList();

    // 2. Electricity Usage Line Chart (last 6 months)
    final elecMap = <String, double>{};
    for (var b in bills) {
      elecMap[b.month] = (elecMap[b.month] ?? 0.0) + b.electricityUnits;
    }
    final sortedElecMonths = elecMap.keys.toList()..sort();
    final lineData = sortedElecMonths.skip(sortedElecMonths.length > 6 ? sortedElecMonths.length - 6 : 0).map((m) {
      return _ChartData(m, elecMap[m]!);
    }).toList();

    // 3. Occupancy Donut Chart
    final occupied = rooms.where((r) => r.status == 'Occupied').length.toDouble();
    final vacant = rooms.where((r) => r.status == 'Vacant').length.toDouble();
    final donutData = [
      _PieData('Occupied', occupied, LedgerlyColors.teal),
      _PieData('Vacant', vacant, LedgerlyColors.inkSoftLight),
    ];

    return Column(
      children: [
        // Rent Bar Chart
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              height: 200,
              child: SfCartesianChart(
                title: const ChartTitle(text: 'Monthly Rent Collection (INR)'),
                primaryXAxis: const CategoryAxis(),
                series: <CartesianSeries>[
                  ColumnSeries<_ChartData, String>(
                    dataSource: barData,
                    xValueMapper: (_ChartData data, _) => data.x,
                    yValueMapper: (_ChartData data, _) => data.y,
                    color: LedgerlyColors.gold,
                  )
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Electricity Line Chart
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              height: 200,
              child: SfCartesianChart(
                title: const ChartTitle(text: 'Electricity Consumption (Units)'),
                primaryXAxis: const CategoryAxis(),
                series: <CartesianSeries>[
                  LineSeries<_ChartData, String>(
                    dataSource: lineData,
                    xValueMapper: (_ChartData data, _) => data.x,
                    yValueMapper: (_ChartData data, _) => data.y,
                    color: LedgerlyColors.amber,
                  )
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Occupancy Donut Chart
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              height: 200,
              child: SfCircularChart(
                title: const ChartTitle(text: 'Occupancy Rate'),
                legend: const Legend(isVisible: true),
                series: <CircularSeries>[
                  DoughnutSeries<_PieData, String>(
                    dataSource: donutData,
                    xValueMapper: (_PieData data, _) => data.x,
                    yValueMapper: (_PieData data, _) => data.y,
                    pointColorMapper: (_PieData data, _) => data.color,
                    dataLabelSettings: const DataLabelSettings(isVisible: true),
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReminders(List<TenantBillEntity> bills, List<TenantEntity> tenants) {
    if (bills.isEmpty && tenants.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: Text('No active reminders or warnings.')),
        ),
      );
    }

    return Column(
      children: [
        // Overdue/Due Soon bills
        ...bills.map((bill) {
          final diff = bill.dueDate.difference(DateTime.now()).inDays;
          final isOverdue = diff < 0;
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: isOverdue ? LedgerlyColors.coralSoft : LedgerlyColors.amberSoft,
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedAlert01,
                  color: isOverdue ? LedgerlyColors.coral : LedgerlyColors.amber,
                ),
              ),
              title: Text('${bill.tenantName} - Room ${bill.roomNumber}'),
              subtitle: Text(
                isOverdue ? 'Overdue by ${diff.abs()} days' : 'Due in $diff days',
                style: TextStyle(
                  color: isOverdue ? LedgerlyColors.coral : LedgerlyColors.amber,
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: Text(
                '₹${bill.total.toStringAsFixed(0)}',
                style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.bold),
              ),
            ),
          );
        }),

        // Leases expiring
        ...tenants.map((tenant) {
          final diff = tenant.agreementEndDate.difference(DateTime.now()).inDays;
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: LedgerlyColors.indigoSoft,
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedAgreement01,
                  color: LedgerlyColors.indigo,
                ),
              ),
              title: Text('${tenant.name} - Room ${tenant.roomNumber}'),
              subtitle: Text(
                'Lease expires in $diff days',
                style: const TextStyle(
                  color: LedgerlyColors.indigo,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _ChartData {
  final String x;
  final double y;
  _ChartData(this.x, this.y);
}

class _PieData {
  final String x;
  final double y;
  final Color color;
  _PieData(this.x, this.y, this.color);
}
