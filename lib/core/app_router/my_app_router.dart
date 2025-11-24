import 'package:expense_manager/Screen/AddExpensePage.dart';
import 'package:expense_manager/Screen/HomePage.dart';
import 'package:expense_manager/Screen/LandingPage.dart';
import 'package:expense_manager/Screen/Login&RegisterPage.dart';
import 'package:expense_manager/Screen/LoginPage.dart';
import 'package:expense_manager/Screen/OnboardingPage.dart';
import 'package:expense_manager/core/app_router/my_app_router_const.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../di/injection_container.dart';

class AuthNotifier extends ChangeNotifier {
  bool _isLoggedIn = false;

  bool get isLoggedIn => _isLoggedIn;

  AuthNotifier() {
    _checkAuthState();
  }

  Future<bool> _checkAuthState() async {
    _isLoggedIn = FirebaseAuth.instance.currentUser != null;
    notifyListeners();
    return _isLoggedIn;
  }

  Future<void> login() async {
    _isLoggedIn = true;
    notifyListeners();
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    _isLoggedIn = false;
    notifyListeners();
  }
}

final authNotifier = AuthNotifier();

class MyAppRouter {
  final AuthNotifier authNotifier;

  MyAppRouter(this.authNotifier);

  late final router = GoRouter(
    refreshListenable: authNotifier,
    initialLocation: MyAppRouteConst.onboarding,
    redirect: (BuildContext context, GoRouterState state) async {
      final isLoggedIn = await authNotifier._checkAuthState();
      final isOnboarding = state.matchedLocation == MyAppRouteConst.onboarding;
      final isLogin = state.matchedLocation == MyAppRouteConst.login;
      final isSignIn = state.matchedLocation == MyAppRouteConst.signUp;
      var pref = sl<SharedPreferences>();
      final isLandingComp = pref.getBool('isFirstLaunch') ?? true;

      print("isLogged IN : $isLoggedIn");

      if (!isLoggedIn && !isLandingComp && !isOnboarding && !isSignIn && !isLogin) {
        return MyAppRouteConst.login;
      }

      // If user is logged in and on login/signin/onboarding page, redirect to home
      if (isLoggedIn && (isLogin || isSignIn || isOnboarding)) {
        return MyAppRouteConst.home;
      }

      // No redirect needed
      return null;
    },
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
    ],
  );
}
