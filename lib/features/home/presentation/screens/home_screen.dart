import 'package:expense_manager/core/extensions/theme_extension.dart';
import 'package:expense_manager/core/widgets/drawer.dart';
import 'package:expense_manager/features/tenant/domain/entities/tenant_entity.dart';
import 'package:expense_manager/features/tenant/presentation/bloc/tenant_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/routes/my_app_router_const.dart';
import '../../../../core/theme/bloc/theme_bloc.dart';
import '../../../../core/theme/bloc/theme_event.dart';
import '../../../../core/theme/bloc/theme_state.dart';
import '../../../user/presentation/bloc/user_bloc.dart';
import '../../../user/presentation/bloc/user_state.dart';
import '../../../user/presentation/bloc/user_event.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    context.read<TenantBloc>().add(LoadTenantsEvent());
    final userBloc = context.read<UserBloc>();
    if (userBloc.state is UserInitial) {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        userBloc.add(LoadUserEvent(userId));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Padding(
            padding: const EdgeInsets.all(8),
            child: HugeIcon(
              size: 18.0,
              icon: HugeIcons.strokeRoundedMenu01,
              color: context.theme.colorScheme.onSurface,
            ),
          ),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        actions: [
          BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, themeState) {
              final isDark =
                  themeState.themeMode == ThemeMode.dark ||
                  (themeState.themeMode == ThemeMode.system &&
                      WidgetsBinding
                              .instance
                              .platformDispatcher
                              .platformBrightness ==
                          Brightness.dark);
              return IconButton(
                icon: Padding(
                  padding: const EdgeInsets.all(8),
                  child: HugeIcon(
                    size: 18.0,
                    icon: isDark
                        ? HugeIcons.strokeRoundedSun01
                        : HugeIcons.strokeRoundedMoon02,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                onPressed: () {
                  context.read<ThemeBloc>().add(const ToggleThemeEvent());
                },
              );
            },
          ),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              child: HugeIcon(
                size: 18.0,
                icon: HugeIcons.strokeRoundedNotification01,
                color: context.theme.colorScheme.onSurface,
              ),
            ),
            onPressed: () {},
          ),
        ],
      ),
      drawer: const HomeDrawer(),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadInitialData();
          return Future.delayed(const Duration(seconds: 1));
        },
        backgroundColor: context.theme.scaffoldBackgroundColor,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Dashboard', style: context.theme.textTheme.headlineSmall),
                Text(
                  'Your property at a glance',
                  style: context.theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                BlocBuilder<TenantBloc, TenantState>(
                  builder: (context, state) {
                    if (state is TenantLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is TenantError) {
                      return Center(
                        child: Text(
                          'Failed to load tenants: ${state.failure.title}',
                          style: TextStyle(
                            color: context.theme.colorScheme.error,
                          ),
                        ),
                      );
                    } else if (state is TenantLoaded) {
                      final activeTenants = state.tenants
                          .where((t) => t.status == TenantStatus.active)
                          .toList();
                      final totalRent = activeTenants.fold<double>(
                        0,
                        (sum, item) => sum + item.rent,
                      );

                      return Column(
                        children: [
                          Row(
                            children: [
                              _buildStatCard(
                                'Active Tenants',
                                '${activeTenants.length}',
                                context.theme.colorScheme.primary,
                                HugeIcons.strokeRoundedUserGroup,
                              ),
                              const SizedBox(width: 16),
                              _buildStatCard(
                                'Monthly Rent',
                                totalRent.toStringAsFixed(0),
                                context.theme.colorScheme.secondary,
                                HugeIcons.strokeRoundedRupee,
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),
                          Row(
                            children: [
                              _buildStatCard(
                                'Occupied Rooms',
                                '${activeTenants.length}',
                                context.theme.colorScheme.primary,
                                HugeIcons.strokeRoundedHouse01,
                              ),
                              const SizedBox(width: 16),
                              _buildStatCard(
                                'Vacant Rooms',
                                totalRent.toStringAsFixed(0),
                                context.theme.colorScheme.secondary,
                                HugeIcons.strokeRoundedHouse02,
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),
                          Row(
                            children: [
                              _buildActionCard(
                                'Add Tenant',
                                HugeIcons.strokeRoundedUserAdd01,
                                context.theme.colorScheme.primary,
                                () =>
                                    context.push(MyAppRouteConst.addEditTenant),
                              ),
                              const SizedBox(width: 16),
                              _buildActionCard(
                                'View All Tenants',
                                HugeIcons.strokeRoundedUserGroup,
                                context.theme.colorScheme.secondary,
                                () => context.push(MyAppRouteConst.tenants),
                              ),
                            ],
                          ),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String amount,
    Color color,
    dynamic icon,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: context.theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HugeIcon(size: 20.0, icon: icon, color: color),
            const SizedBox(height: 12),
            Text(amount, style: context.theme.textTheme.headlineMedium),
            Text(
              title,
              style: context.theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    String title,
    dynamic icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              HugeIcon(size: 20.0, icon: icon, color: color),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
