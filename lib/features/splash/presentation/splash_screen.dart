import 'package:expense_manager/core/service/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/enums/user_role.dart';
import '../../../core/routes/my_app_router_const.dart';
import '../../../core/service/i_local_storage_service.dart';
import '../../../core/service/impl/auth_service_impl.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late final AuthService authService;
  late final UserRole role;
  late final ILocalStorageService local;
  late final bool isLandingComp;

  @override
  void initState() {
    manageRoute();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/icons/expense_logo.png",
              width: 120,
              height: 120,
            ),
            const SizedBox(height: 20),
            const Text(
              "Expense Manager",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> manageRoute() async {
    authService = sl<AuthServiceImpl>();
    local = sl<ILocalStorageService>();

    role = await authService.currentRole;
    isLandingComp = await local.isOnBoardingComplete ?? false;

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    if (!isLandingComp) {
      context.go(MyAppRouteConst.onboarding);
      return;
    }

    switch (role) {
      case UserRole.authenticated:
        final hasSynced = await local.hasSyncedOnce;
        if (hasSynced) {
          context.go(MyAppRouteConst.home);
        } else {
          context.go(MyAppRouteConst.sync);
        }
        break;

      case UserRole.unauthenticated:
      case UserRole.unknown:
        context.go(MyAppRouteConst.login);
        break;
    }
  }
}
