import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_manager/core/service/i_local_storage_service.dart';
import 'theme_event.dart';
import 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final ILocalStorageService _localStorageService;

  ThemeBloc(this._localStorageService) : super(const ThemeState(ThemeMode.system)) {
    on<LoadThemeEvent>(_onLoadTheme);
    on<ToggleThemeEvent>(_onToggleTheme);
  }

  Future<void> _onLoadTheme(LoadThemeEvent event, Emitter<ThemeState> emit) async {
    final themeStr = await _localStorageService.themeMode;
    if (themeStr == 'light') {
      emit(const ThemeState(ThemeMode.light));
    } else if (themeStr == 'dark') {
      emit(const ThemeState(ThemeMode.dark));
    } else {
      emit(const ThemeState(ThemeMode.system));
    }
  }

  Future<void> _onToggleTheme(ToggleThemeEvent event, Emitter<ThemeState> emit) async {
    // If currently system, consider it light for the first toggle
    final isCurrentlyDark = state.themeMode == ThemeMode.dark || 
        (state.themeMode == ThemeMode.system && WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark);
    
    final newTheme = isCurrentlyDark ? ThemeMode.light : ThemeMode.dark;
    await _localStorageService.setThemeMode(newTheme.name);
    emit(ThemeState(newTheme));
  }
}
