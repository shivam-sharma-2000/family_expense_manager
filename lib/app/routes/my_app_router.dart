import 'package:expense_manager/features/expense/presentation/pages/add_expense_screen.dart';
import 'package:expense_manager/features/auth/presentation/register_screen.dart';
import 'package:expense_manager/features/splash/presentation/splash_screen.dart';
import 'package:expense_manager/features/sync/presentation/pages/sync_page.dart';
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
        name: 'add_expense',
        path: '${MyAppRouteConst.addExpense}/:type',
        pageBuilder: (context, state) => MaterialPage(
          child: AddExpenseScreen(from: state.pathParameters['type'] ?? ''),
        ),
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
          final user = state.extra as UserEntity;
          return const MaterialPage(child: SyncPage());
        },
      ),
    ],
  );
}
