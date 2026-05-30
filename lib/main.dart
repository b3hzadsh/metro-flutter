// مسیر: lib/main.dart

import 'package:flutter/material.dart';
import 'injection_container.dart' as di;
import 'features/metro_routing/presentation/pages/metro_routing_page.dart'; // اضافه شدن صفحه

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Metro App',
      // راست‌چین کردن قالب برای پشتیبانی بهتر از زبان فارسی
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      // قرار دادن صفحه مسیریاب به عنوان صفحه اصلی
      home: const MetroRoutingPage(), 
    );
  }
}