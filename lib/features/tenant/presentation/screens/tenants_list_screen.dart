import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../core/extensions/theme_extension.dart';
import '../../../../core/routes/my_app_router_const.dart';
import '../../domain/entities/tenant_entity.dart';
import '../bloc/tenant_bloc.dart';

class TenantsListScreen extends StatefulWidget {
  const TenantsListScreen({super.key});

  @override
  State<TenantsListScreen> createState() => _TenantsListScreenState();
}

class _TenantsListScreenState extends State<TenantsListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<TenantBloc>().add(LoadTenantsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('Tenants', style: context.theme.textTheme.headlineMedium),
        leading: IconButton(
          icon: HugeIcon(
            size: 18.0,
            icon: HugeIcons.strokeRoundedArrowLeft01,
            color: context.theme.colorScheme.onSurface,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: HugeIcon(
              size: 18.0,
              icon: HugeIcons.strokeRoundedAdd01,
              color: context.theme.colorScheme.primary,
            ),
            onPressed: () {
              context.push(MyAppRouteConst.addEditTenant);
            },
          ),
        ],
      ),
      body: BlocBuilder<TenantBloc, TenantState>(
        builder: (context, state) {
          if (state is TenantLoading) {
            return Center(
              child: CircularProgressIndicator(color: context.theme.colorScheme.primary),
            );
          } else if (state is TenantError) {
            return Center(
              child: Text(
                'Error: ${state.failure.title}',
                style: TextStyle(color: context.theme.colorScheme.error),
              ),
            );
          } else if (state is TenantLoaded) {
            if (state.tenants.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    HugeIcon(
                      size: 18.0,
                      icon: HugeIcons.strokeRoundedUserGroup,
                      color: context.theme.colorScheme.onSurface.withValues(alpha: 0.54),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No tenants added yet',
                      style: TextStyle(color: context.theme.colorScheme.onSurface.withValues(alpha: 0.54), fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        context.push(MyAppRouteConst.addEditTenant);
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Add Tenant'),
                    ),
                  ],
                ),
              );
            }

            return _buildDashboardAndList(state.tenants);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildDashboardAndList(List<TenantEntity> tenants) {
    final activeTenants = tenants
        .where((t) => t.status == TenantStatus.active)
        .toList();
    final totalRent = activeTenants.fold<double>(
      0,
      (sum, item) => sum + item.rent,
    );

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Total Monthly Rent',
                    value: '₹${totalRent.toStringAsFixed(0)}',
                    icon: HugeIcons.strokeRoundedWallet01,
                    color: context.theme.colorScheme.secondary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatCard(
                    title: 'Occupied Rooms',
                    value: '${activeTenants.length}',
                    icon: HugeIcons.strokeRoundedHome01,
                    color: context.theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final tenant = tenants[index];
              return _TenantCard(tenant: tenant);
            }, childCount: tenants.length),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final dynamic icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.theme.colorScheme.onSurface.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: HugeIcon(size: 18.0, icon: icon, color: color),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: context.theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: context.theme.textTheme.bodySmall?.copyWith(
              color: context.theme.colorScheme.onSurface.withValues(alpha: 0.54),
            ),
          ),
        ],
      ),
    );
  }
}

class _TenantCard extends StatelessWidget {
  final TenantEntity tenant;

  const _TenantCard({required this.tenant});

  @override
  Widget build(BuildContext context) {
    final isActive = tenant.status == TenantStatus.active;

    return GestureDetector(
      onTap: () {
        context.push('${MyAppRouteConst.tenantDetail}/${tenant.id}');
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.theme.cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: isActive
                  ? context.theme.colorScheme.primary.withValues(alpha: 0.1)
                  : context.theme.colorScheme.error.withValues(alpha: 0.1),
              radius: 24,
              child: Text(
                tenant.name.substring(0, 1).toUpperCase(),
                style: TextStyle(
                  color: isActive ? context.theme.colorScheme.primary : context.theme.colorScheme.error,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tenant.name,
                    style: context.theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      HugeIcon(
                        size: 18.0,
                        icon: HugeIcons.strokeRoundedHome01,
                        color: context.theme.colorScheme.onSurface.withValues(alpha: 0.54),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Room ${tenant.roomNumber}',
                        style: context.theme.textTheme.bodySmall?.copyWith(
                          color: context.theme.colorScheme.onSurface.withValues(alpha: 0.54),
                        ),
                      ),
                      const SizedBox(width: 12),
                      HugeIcon(
                        size: 18.0,
                        icon: HugeIcons.strokeRoundedWallet01,
                        color: context.theme.colorScheme.onSurface.withValues(alpha: 0.54),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '₹${tenant.rent.toStringAsFixed(0)}/mo',
                        style: context.theme.textTheme.bodySmall?.copyWith(
                          color: context.theme.colorScheme.onSurface.withValues(alpha: 0.54),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isActive
                    ? context.theme.colorScheme.secondary.withValues(alpha: 0.1)
                    : context.theme.colorScheme.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isActive ? 'Active' : 'Vacated',
                style: TextStyle(
                  color: isActive ? context.theme.colorScheme.secondary : context.theme.colorScheme.error,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
