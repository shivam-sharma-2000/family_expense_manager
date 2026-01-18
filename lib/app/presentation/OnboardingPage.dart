import 'package:expense_manager/core/enums/user_role.dart';
import 'package:expense_manager/core/service/impl/local_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/di/injection_container.dart';
import '../../core/service/i_local_storage_service.dart';
import '../routes/my_app_router_const.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({Key? key}) : super(key: key);

  @override
  _OnboardingPageState createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 3;

  final List<Map<String, String>> _onboardingData = [
    {
      'title': 'Track Your Expenses',
      'description': 'Easily record and categorize your daily expenses to understand where your money goes.',
      'image': '💰',
    },
    {
      'title': 'Visualize Your Spending',
      'description': 'Get insights with beautiful charts and graphs to track your financial habits.',
      'image': '📊',
    },
    {
      'title': 'Set Budgets & Goals',
      'description': 'Create budgets and savings goals to achieve your financial objectives.',
      'image': '🎯',
    },
  ];

  Future<void> _completeOnboarding() async {
    final local = sl<ILocalStorageService>();
    local.setOnBoardingComplete(true);
    if (!mounted) return;
    context.pushReplacement(MyAppRouteConst.landing);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _onboardingData.length,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemBuilder: (context, index) {
                  return _buildPage(_onboardingData[index]);
                },
              ),
            ),
            _buildPageIndicator(),
            _buildNavigationButtons(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(Map<String, String> data) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            data['image']!,
            style: const TextStyle(fontSize: 100),
          ),
          const SizedBox(height: 40),
          Text(
            data['title']!,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            data['description']!,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(
        _totalPages,
        (index) => _indicator(index == _currentPage),
      ),
    );
  }

  Widget _indicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      height: 8.0,
      width: isActive ? 24.0 : 16.0,
      decoration: BoxDecoration(
        color: isActive ? Theme.of(context).primaryColor : Colors.grey[300],
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: _currentPage == _totalPages - 1
                ? null
                : () => _completeOnboarding(),
            child: const Text('Skip'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_currentPage == _totalPages - 1) {
                _completeOnboarding();
              } else {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
            },
            child: Text(_currentPage == _totalPages - 1 ? 'Get Started' : 'Next'),
          ),
        ],
      ),
    );
  }
}
