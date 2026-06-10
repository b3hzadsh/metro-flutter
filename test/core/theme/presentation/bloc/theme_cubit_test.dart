import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:metro/core/theme/data/datasources/theme_local_data_source.dart';
import 'package:metro/core/theme/presentation/bloc/theme_cubit.dart';

class MockThemeLocalDataSource extends Mock implements ThemeLocalDataSource {}

void main() {
  late ThemeCubit themeCubit;
  late MockThemeLocalDataSource mockThemeLocalDataSource;

  setUpAll(() {
    registerFallbackValue(ThemeMode.system);
  });

  setUp(() {
    mockThemeLocalDataSource = MockThemeLocalDataSource();
    when(() => mockThemeLocalDataSource.getCachedThemeMode())
        .thenReturn(ThemeMode.light);
    when(() => mockThemeLocalDataSource.cacheThemeMode(any()))
        .thenAnswer((_) async => {});
    
    themeCubit = ThemeCubit(themeLocalDataSource: mockThemeLocalDataSource);
  });

  test('initial state should be light mode if cached value is light', () {
    expect(themeCubit.state, ThemeMode.light);
  });

  test('toggleTheme should emit dark mode when current state is light', () {
    themeCubit.toggleTheme();
    expect(themeCubit.state, ThemeMode.dark);
    verify(() => mockThemeLocalDataSource.cacheThemeMode(ThemeMode.dark)).called(1);
  });

  test('toggleTheme should emit light mode when current state is dark', () {
    // Manually set state to dark by toggling once
    themeCubit.toggleTheme(); 
    expect(themeCubit.state, ThemeMode.dark);

    // Toggle back to light
    themeCubit.toggleTheme();
    expect(themeCubit.state, ThemeMode.light);
    verify(() => mockThemeLocalDataSource.cacheThemeMode(ThemeMode.light)).called(1);
  });
}
