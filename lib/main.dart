import 'package:expense_manager/core/di/injection_container.dart';
import 'package:expense_manager/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:expense_manager/features/expense/presentation/bloc/expense_bloc.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_manager/app/theme/app_theme.dart';
import 'package:expense_manager/features/user/presentation/bloc/user_bloc.dart';
import 'package:expense_manager/features/family/presentation/bloc/family_bloc.dart';
import 'package:expense_manager/app/theme/bloc/theme_bloc.dart';
import 'package:expense_manager/app/theme/bloc/theme_event.dart';
import 'package:expense_manager/app/theme/bloc/theme_state.dart';
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
        BlocProvider<UserBloc>(create: (context) => sl<UserBloc>()),
        BlocProvider<FamilyBloc>(create: (context) => sl<FamilyBloc>()),
        BlocProvider<ThemeBloc>(
          create: (context) => sl<ThemeBloc>()..add(const LoadThemeEvent()),
        ),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'Expense Manager',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeState.themeMode,
            routerConfig: router,
          );
        },
      ),
    );
  }
}
