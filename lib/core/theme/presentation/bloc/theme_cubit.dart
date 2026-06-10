import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/theme_local_data_source.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  final ThemeLocalDataSource themeLocalDataSource;

  ThemeCubit({required this.themeLocalDataSource}) 
      : super(themeLocalDataSource.getCachedThemeMode());

  void toggleTheme() {
    final newMode = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    themeLocalDataSource.cacheThemeMode(newMode);
    emit(newMode);
  }

  bool get isDarkMode => state == ThemeMode.dark;
}
