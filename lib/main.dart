import 'package:expense_manager/Screen/LoginPage.dart';
import 'package:expense_manager/Screen/MainApp.dart';
import 'package:expense_manager/core/app_router/my_app_router.dart';
import 'package:expense_manager/core/di/injection_container.dart';
import 'package:expense_manager/database/DBHelper.dart';
import 'package:expense_manager/features/expense/presentation/bloc/expense_bloc.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Screen/LandingPage.dart';
import 'Screen/OnboardingPage.dart';
import 'features/expense/domain/repositories/expense_repository.dart';
import 'features/expense/presentation/bloc/expense_event.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupLocator();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAppCheck.instance.activate(
    providerAndroid: const AndroidPlayIntegrityProvider()
  );
  
  // Initialize auth notifier
  final authNotifier = AuthNotifier();

  runApp(
    MyApp(authNotifier: authNotifier),
  );

}

class MyApp extends StatelessWidget {
  final AuthNotifier authNotifier;
  
  const MyApp({super.key, required this.authNotifier});

  @override
  Widget build(BuildContext context) {
    final router = MyAppRouter(authNotifier).router;
    
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Expense Manager',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.transparent,
          iconTheme: IconThemeData(color: Color(0xFF1E293B)),
          titleTextStyle: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Color(0xFF6C63FF),
          unselectedItemColor: Color(0xFF94A3B8),
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          elevation: 10,
        ),
      ),
      routerConfig: router,
    );
  }
}
