import 'package:expense_manager/core/service/impl/auth_service_impl.dart';
import 'package:expense_manager/core/service/impl/local_storage_service.dart';
import 'package:expense_manager/features/expense/presentation/pages/AddExpensePage.dart';
import 'package:expense_manager/features/auth/presentation/Login&RegisterPage.dart';
import 'package:expense_manager/features/splash/presentation/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/LoginPage.dart';
import '../presentation/HomePage.dart';
import '../presentation/LandingPage.dart';
import '../presentation/OnboardingPage.dart';
import 'my_app_router_const.dart';

class MyAppRouter {
  MyAppRouter();

  late final router = GoRouter(
    initialLocation: MyAppRouteConst.splash,
    routes: [
      GoRoute(
        name: 'onboarding',
        path: MyAppRouteConst.onboarding,
        pageBuilder: (context, state) =>
            const MaterialPage(child: OnboardingPage()),
      ),
      GoRoute(
        name: 'landing',
        path: MyAppRouteConst.landing,
        pageBuilder: (context, state) =>
            const MaterialPage(child: LandingPage()),
      ),
      GoRoute(
        name: 'home',
        path: MyAppRouteConst.home,
        pageBuilder: (context, state) => const MaterialPage(child: HomePage()),
      ),
      GoRoute(
        name: 'add_expense',
        path: '${MyAppRouteConst.add_expense}/:type',
        pageBuilder: (context, state) => MaterialPage(
          child: AddExpensePage(from: state.pathParameters['type'] ?? ''),
        ),
      ),
      GoRoute(
        name: 'login',
        path: MyAppRouteConst.login,
        pageBuilder: (context, state) {
          return const MaterialPage(child: LoginPage());
        },
      ),
      GoRoute(
        name: 'sign_up',
        path: MyAppRouteConst.signUp,
        pageBuilder: (context, state) {
          return const MaterialPage(child: LoginAndRegisterPage());
        },
      ),
      GoRoute(
        name: 'splash',
        path: MyAppRouteConst.splash,
        pageBuilder: (context, state) {
          return const MaterialPage(child: SplashScreen());
        },
      ),
    ],
  );
}
