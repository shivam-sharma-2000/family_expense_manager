import 'package:expense_manager/core/di/injection_container.dart';
import 'package:expense_manager/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:expense_manager/features/expense/presentation/bloc/expense_bloc.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app/routes/my_app_router.dart';
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

  runApp(
    const MyApp(),
  );

}

class MyApp extends StatelessWidget {
  
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = MyAppRouter().router;
    
    return MultiBlocProvider(
      providers: [
        BlocProvider<ExpenseBloc>(create: (context) => sl<ExpenseBloc>()),
        BlocProvider<AuthBloc>(create: (context) => sl<AuthBloc>()),
      ],
      child: MaterialApp.router(
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
      ),
    );
  }
}
