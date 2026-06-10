import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class ThemeLocalDataSource {
  Future<void> cacheThemeMode(ThemeMode mode);
  ThemeMode getCachedThemeMode();
}

class ThemeLocalDataSourceImpl implements ThemeLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String key = 'theme_mode';

  ThemeLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> cacheThemeMode(ThemeMode mode) async {
    await sharedPreferences.setString(key, mode.toString());
  }

  @override
  ThemeMode getCachedThemeMode() {
    final modeStr = sharedPreferences.getString(key);
    if (modeStr == null) return ThemeMode.system;
    
    return ThemeMode.values.firstWhere(
      (e) => e.toString() == modeStr,
      orElse: () => ThemeMode.system,
    );
  }
}
