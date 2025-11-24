import 'package:expense_manager/Screen/LoginPage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/app_router/my_app_router_const.dart';
import 'HomePage.dart';
import 'Login&RegisterPage.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;
  @override
  void initState() {
    // TODO: implement initState
    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // control transition threshold
    const double fadeStart = 50;
    const double fadeEnd = 200;

    double t = (_scrollOffset - fadeStart) / (fadeEnd - fadeStart);
    t = t.clamp(0.0, 1.0);

    // Big icon fades out when scrolling
    final double bigIconOpacity = 1.0 - t;
    final double bigIconScale = 1.0 - (t * 0.4);

    // Small icon fades in
    final double smallIconOpacity = t;


    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    'Welcome to',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      // AnimatedOpacity(
                      //   duration: const Duration(milliseconds: 300),
                      //   opacity: smallIconOpacity,
                      //   child: const Center(
                      //     child: Padding(
                      //       padding: EdgeInsets.only(top: 10, bottom: 10, right: 10),
                      //       child: Icon(
                      //         Icons.account_balance_wallet_rounded,
                      //         size: 30,
                      //         color: Color(0xFF3B82F6),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) =>
                            FadeTransition(opacity: animation, child: child),
                        child: _scrollOffset > 120 // show only after scroll threshold
                            ? const Padding(
                          key: ValueKey('visibleIcon'),
                          padding: EdgeInsets.only(right: 8),
                          child: Icon(
                            Icons.account_balance_wallet_rounded,
                            size: 28,
                            color: Color(0xFF2563EB),
                          ),
                        )
                            : const SizedBox(
                          key: ValueKey('hiddenIcon'),
                          width: 0,
                          height: 0,
                        ),
                      ),
                      Text(
                        'Expense Manager',
                        style: GoogleFonts.poppins(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2563EB),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Take control of your finances and track every expense with ease. Start managing your money smarter today!',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            // Illustration
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  children: [
                    AnimatedOpacity(
                      opacity: bigIconOpacity,
                      duration: const Duration(milliseconds: 100),
                      child: Transform.scale(
                        scale: bigIconScale,
                        child: Container(
                          height: size.height * 0.35,
                          margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Icon(
                              Icons.account_balance_wallet_rounded,
                              size: 120,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Features
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: Column(
                        children: [
                          _buildFeatureTile(
                            icon: Icons.insights_rounded,
                            title: 'Track Expenses',
                            subtitle: 'Monitor your spending with detailed insights',
                          ),
                          const SizedBox(height: 16),
                          _buildFeatureTile(
                            icon: Icons.pie_chart_rounded,
                            title: 'Visual Reports',
                            subtitle: 'Understand your finances with beautiful charts',
                          ),
                          const SizedBox(height: 16),
                          _buildFeatureTile(
                            icon: Icons.notifications_active_rounded,
                            title: 'Smart Reminders',
                            subtitle: 'Never miss a bill payment again',
                          ),
                        ],
                      ),
                    ),

                    // Buttons
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          // Get Started Button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: () {
                                context.pushReplacement(MyAppRouteConst.login);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2563EB),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: Text(
                                'Get Started',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Guest Button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => const HomePage()),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF2563EB),
                                side: const BorderSide(color: Color(0xFF2563EB)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: Text(
                                'Continue as Guest',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFeatureTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF2563EB),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
