import 'package:expense_manager/features/auth/presentation/register_screen.dart';
import 'package:expense_manager/features/splash/presentation/splash_screen.dart';
import 'package:expense_manager/features/sync/presentation/pages/sync_page.dart';
import 'package:expense_manager/features/tenant/presentation/screens/tenants_list_screen.dart';
import 'package:expense_manager/features/tenant/presentation/screens/add_edit_tenant_screen.dart';
import 'package:expense_manager/features/tenant/presentation/screens/tenant_detail_screen.dart';
import 'package:expense_manager/features/tenant/presentation/screens/generate_bill_screen.dart';
import 'package:expense_manager/features/tenant/presentation/screens/add_payment_screen.dart';
import 'package:expense_manager/features/tenant/presentation/screens/rooms_screen.dart';
import 'package:expense_manager/features/tenant/presentation/screens/electricity_screen.dart';
import 'package:expense_manager/features/tenant/presentation/screens/bills_list_screen.dart';
import 'package:expense_manager/features/tenant/presentation/screens/reports_screen.dart';
import 'package:expense_manager/features/tenant/presentation/screens/settings_screen.dart';
import 'package:expense_manager/features/user/domain/entities/user_entity.dart';
import 'package:expense_manager/features/user/presentation/screens/edit_profile_screen.dart';
import 'package:expense_manager/features/user/presentation/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/onboarding/presentation/screens/landing_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import 'my_app_router_const.dart';

class MyAppRouter {
  // 1. Private constructor
  MyAppRouter._internal();

  // 2. Single instance
  static final MyAppRouter _instance = MyAppRouter._internal();

  // 3. Accessor
  factory MyAppRouter() => _instance;

  // 4. Router
  late final GoRouter router = GoRouter(
    initialLocation: MyAppRouteConst.splash,
    routes: [
      GoRoute(
        name: 'onboarding',
        path: MyAppRouteConst.onboarding,
        pageBuilder: (context, state) =>
            const MaterialPage(child: OnboardingScreen()),
      ),
      GoRoute(
        name: 'landing',
        path: MyAppRouteConst.landing,
        pageBuilder: (context, state) =>
            const MaterialPage(child: LandingScreen()),
      ),
      GoRoute(
        name: 'home',
        path: MyAppRouteConst.home,
        pageBuilder: (context, state) =>
            const MaterialPage(child: HomeScreen()),
      ),
      GoRoute(
        name: 'login',
        path: MyAppRouteConst.login,
        pageBuilder: (context, state) =>
            const MaterialPage(child: LoginScreen()),
      ),
      GoRoute(
        name: 'sign_up',
        path: MyAppRouteConst.signUp,
        pageBuilder: (context, state) =>
            const MaterialPage(child: RegisterScreen()),
      ),
      GoRoute(
        name: 'splash',
        path: MyAppRouteConst.splash,
        pageBuilder: (context, state) =>
            const MaterialPage(child: SplashScreen()),
      ),
      GoRoute(
        name: 'profile',
        path: MyAppRouteConst.profile,
        pageBuilder: (context, state) =>
            const MaterialPage(child: ProfileScreen()),
      ),
      GoRoute(
        name: 'edit_profile',
        path: MyAppRouteConst.editProfile,
        pageBuilder: (context, state) {
          final user = state.extra as UserEntity;
          return MaterialPage(child: EditProfileScreen(user: user));
        },
      ),
      GoRoute(
        name: 'sync',
        path: MyAppRouteConst.sync,
        pageBuilder: (context, state) {
          return const MaterialPage(child: SyncPage());
        },
      ),

      GoRoute(
        name: 'tenants',
        path: MyAppRouteConst.tenants,
        pageBuilder: (context, state) {
          return const MaterialPage(child: TenantsListScreen());
        },
      ),
      GoRoute(
        name: 'add_tenant',
        path: MyAppRouteConst.addEditTenant,
        pageBuilder: (context, state) {
          return const MaterialPage(child: AddEditTenantScreen());
        },
      ),
      GoRoute(
        name: 'edit_tenant',
        path: '${MyAppRouteConst.addEditTenant}/:id',
        pageBuilder: (context, state) {
          return MaterialPage(child: AddEditTenantScreen(tenantId: state.pathParameters['id']));
        },
      ),
      GoRoute(
        name: 'tenant_detail',
        path: '${MyAppRouteConst.tenantDetail}/:id',
        pageBuilder: (context, state) {
          return MaterialPage(child: TenantDetailScreen(tenantId: state.pathParameters['id']!));
        },
      ),
      GoRoute(
        name: 'generate_bill',
        path: '${MyAppRouteConst.generateBill}/:id',
        pageBuilder: (context, state) {
          return MaterialPage(child: GenerateBillScreen(tenantId: state.pathParameters['id']!));
        },
      ),
      GoRoute(
        name: 'add_payment',
        path: '${MyAppRouteConst.addPayment}/:id',
        pageBuilder: (context, state) {
          final billId = state.extra as String? ?? '';
          return MaterialPage(child: AddPaymentScreen(tenantId: state.pathParameters['id']!, billId: billId));
        },
      ),
      GoRoute(
        name: 'rooms',
        path: MyAppRouteConst.rooms,
        pageBuilder: (context, state) => const MaterialPage(child: RoomsScreen()),
      ),
      GoRoute(
        name: 'electricity',
        path: MyAppRouteConst.electricity,
        pageBuilder: (context, state) => const MaterialPage(child: ElectricityScreen()),
      ),
      GoRoute(
        name: 'bills',
        path: MyAppRouteConst.bills,
        pageBuilder: (context, state) => const MaterialPage(child: BillsListScreen()),
      ),
      GoRoute(
        name: 'reports',
        path: MyAppRouteConst.reports,
        pageBuilder: (context, state) => const MaterialPage(child: ReportsScreen()),
      ),
      GoRoute(
        name: 'settings',
        path: MyAppRouteConst.settings,
        pageBuilder: (context, state) => const MaterialPage(child: SettingsScreen()),
      ),
    ],
  );
}
