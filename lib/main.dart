// مسیر: lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/presentation/bloc/theme_cubit.dart';
import 'injection_container.dart' as di;
import 'features/metro_routing/presentation/pages/metro_routing_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<ThemeCubit>(),
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, mode) {
          return MaterialApp(
            title: 'Metro App',
            debugShowCheckedModeBanner: false,
            builder: (context, child) {
              return Directionality(textDirection: TextDirection.rtl, child: child!);
            },
            themeMode: mode,
            theme: ThemeData(
              useMaterial3: true,
              fontFamily: 'Vazirmatn',
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF006064),
                surface: const Color(0xFFF8FAFC),
              ),
              scaffoldBackgroundColor: const Color(0xFFF8FAFC),
              cardTheme: CardThemeData(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
                ),
              ),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              fontFamily: 'Vazirmatn',
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF006064),
                brightness: Brightness.dark,
                surface: const Color(0xFF0F172A),
              ),
              scaffoldBackgroundColor: const Color(0xFF0F172A),
              cardTheme: CardThemeData(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
                ),
              ),
            ),
            home: const MetroRoutingPage(),
          );
        },
      ),
    );
  }
}
