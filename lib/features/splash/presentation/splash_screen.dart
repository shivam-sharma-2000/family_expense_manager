import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes/my_app_router_const.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/enums/user_role.dart';
import '../../../core/service/i_local_storage_service.dart';
import '../../../core/service/impl/auth_service_impl.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late final authService;
  late final role;
  late final local;
  late final isLandingComp;

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
    role = await authService.currentRole;
    local = sl<ILocalStorageService>();
    isLandingComp = await local.isOnBoardingComplete ?? false;
    Future.delayed(const Duration(seconds: 2)).then((onValue) {
      if (!mounted) return;
      if (isLandingComp) {
        if (role == UserRole.unauthenticated || role == UserRole.unknown) {
          Future.delayed(const Duration(seconds: 2)).then((onValue) {
            context.go(MyAppRouteConst.login);
          });
        } else if (role == UserRole.authenticated) {
          Future.delayed(const Duration(seconds: 2)).then((onValue) {
            context.go(MyAppRouteConst.home);
          });
        } else {
          return null;
        }
      } else {
        Future.delayed(const Duration(seconds: 2)).then((onValue) {
          context.go(MyAppRouteConst.onboarding);
        });
      }
    });
  }
}
