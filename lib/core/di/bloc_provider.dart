import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/expense/presentation/bloc/expense_bloc.dart';
import '../../features/family/presentation/bloc/family_bloc.dart';
import '../../features/user/presentation/bloc/user_bloc.dart';
import '../theme/bloc/theme_bloc.dart';
import '../theme/bloc/theme_event.dart';
import 'injection_container.dart';

/// A list of all the `BlocProvider`s used in the app.
final blocProviders = [
  BlocProvider<ThemeBloc>(
    create: (context) => sl<ThemeBloc>()..add(const LoadThemeEvent()),
  ),
  BlocProvider<ExpenseBloc>(create: (context) => sl<ExpenseBloc>()),
  BlocProvider<AuthBloc>(create: (context) => sl<AuthBloc>()),
  BlocProvider<UserBloc>(create: (context) => sl<UserBloc>()),
  BlocProvider<FamilyBloc>(create: (context) => sl<FamilyBloc>()),
];
