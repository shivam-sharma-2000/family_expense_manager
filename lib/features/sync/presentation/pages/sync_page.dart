import 'package:flutter/material.dart';
import 'package:expense_manager/core/di/injection_container.dart';
import 'package:expense_manager/features/expense/domain/usecases/sync_expense.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/routes/my_app_router_const.dart';

class SyncPage extends StatefulWidget {
  const SyncPage({super.key});

  @override
  State<SyncPage> createState() => _SyncPageState();
}

class _SyncPageState extends State<SyncPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _startSync();
  }

  Future<void> _startSync() async {
    try {
      final syncExpense = sl<SyncExpense>();
      final result = await syncExpense.call();

      if (!mounted) return;

      result.fold(
        (failure) {
          setState(() => _hasError = true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Sync failed: ${failure.title}')),
          );
        },
        (_) {
          // Success, navigate to home
          context.go(MyAppRouteConst.home);
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _hasError = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An unexpected error occurred during sync'),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const HugeIcon(icon: HugeIcons.strokeRoundedArrowLeft01, color: Colors.white70),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Syncing', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const HugeIcon(icon: HugeIcons.strokeRoundedCancel01, color: Colors.white70),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 60),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Logo
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C2C2C),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Image.asset(
                      'assets/icons/expense_logo.png',
                      errorBuilder: (context, error, stackTrace) => const HugeIcon(
                        icon: HugeIcons.strokeRoundedWallet01,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  // Animated Dots (getting data from Firebase to App)
                  SizedBox(
                    width: 80,
                    child: AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(4, (index) {
                            // Calculate delay for each dot to create a wave effect from right to left
                            final delay = (3 - index) * 0.2;
                            var value = _controller.value - delay;
                            if (value < 0) value += 1.0;

                            // Sine wave opacity calculation
                            final opacity = (value >= 0.0 && value <= 0.5)
                                ? (value * 2)
                                : (1.0 - (value - 0.5) * 2);

                            return Opacity(
                              opacity: opacity.clamp(0.2, 1.0),
                              child: Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFFCB2B), // Firebase yellow
                                  shape: BoxShape.circle,
                                ),
                              ),
                            );
                          }),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 20),
                  // Firebase Logo
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C2C2C),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Image.network(
                      'https://firebase.google.com/downloads/brand-guidelines/PNG/logo-logomark.png',
                      errorBuilder: (context, error, stackTrace) => const HugeIcon(
                        icon: HugeIcons.strokeRoundedCloud,
                        color: Colors.amber,
                        size: 40,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            RichText(
              text: const TextSpan(
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  height: 1.5,
                ),
                children: [
                  TextSpan(
                    text: 'Expense Manager ',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(text: 'automatically keeps your data in sync with '),
                  TextSpan(
                    text: 'Firebase',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text:
                        '. By continuing, you are agreeing to Expense Manager\'s ',
                  ),
                  TextSpan(
                    text: 'terms and conditions',
                    style: TextStyle(
                      color: Color(0xFFFFCB2B), // Match Firebase Yellow
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            RichText(
              text: const TextSpan(
                style: TextStyle(color: Colors.white54, fontSize: 14),
                children: [
                  TextSpan(text: 'Need help? please contact '),
                  TextSpan(
                    text: 'support',
                    style: TextStyle(color: Color(0xFFFFCB2B)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
