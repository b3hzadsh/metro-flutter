// مسیر: integration_test/app_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

// دقت کنید که مسیر فایل main پروژه خود را به درستی وارد کنید
import 'package:metro/main.dart' as app;

void main() {
  // راه‌اندازی موتور تست یکپارچگی فلاتر
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Metro Routing App E2E Test', () {
    testWidgets(
      'باید نقشه را دانلود کند، مسیر را محاسبه کند و نتیجه را روی صفحه نشان دهد',
      (WidgetTester tester) async {
        // ۱. اجرای کل اپلیکیشن
        app.main();

        // منتظر می‌مانیم تا انیمیشن‌های لودینگ اولیه تمام شود و صفحه رندر شود
        await tester.pumpAndSettle();

        // ==========================================
        // فاز ۱: دانلود نقشه از سرور و ذخیره در ObjectBox
        // ==========================================

        // پیدا کردن دکمه آپدیت با استفاده از آیکون آن
        final updateButton = find.byIcon(Icons.cloud_download_outlined);
        expect(updateButton, findsOneWidget); // مطمئن می‌شویم دکمه روی صفحه هست

        // کلیک روی دکمه
        await tester.tap(updateButton);

        // چون دانلود از اینترنت و ذخیره در دیتابیس زمان‌بر است، به تستر می‌گوییم
        // تا زمانی که وضعیت BLoC تغییر کند و اسنک‌بار پیام موفقیت برود، صبر کند.
        // تایم‌اوت را ۵ ثانیه می‌گذاریم تا به سرور متصل شود.
        await tester.pumpAndSettle(const Duration(seconds: 5));

        // ==========================================
        // فاز ۲: وارد کردن نام ایستگاه‌ها (تست دیکشنری فارسی)
        // ==========================================

        // پیدا کردن فیلدهای متنی بر اساس Hint/Label آن‌ها
        final startInput = find.widgetWithText(
          TextField,
          'ایستگاه مبدا (مثال: تجریش)',
        );
        final endInput = find.widgetWithText(
          TextField,
          'ایستگاه مقصد (مثال: دروازه دولت)',
        );

        // تایپ کردن عبارات فارسی توسط ربات تستر
        await tester.enterText(startInput, 'تجریش');
        await tester.enterText(endInput, 'تئاتر شهر');

        // بستن کیبورد برای جلوگیری از مسدود شدن دکمه‌ها
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();

        // ==========================================
        // فاز ۳: درخواست مسیریابی و اجرای دایجسترا
        // ==========================================

        final routeButton = find.text('محاسبه مسیر');
        await tester.tap(routeButton);

        // منتظر می‌مانیم تا محاسبات تمام شود و لیست مسیر رندر شود
        await tester.pumpAndSettle();

        // ==========================================
        // فاز ۴: اعتبارسنجی نتایج روی صفحه (UI Assertions)
        // ==========================================

        // بررسی اینکه متن "زمان تخمینی" روی صفحه چاپ شده باشد
        expect(find.textContaining('زمان تخمینی:'), findsOneWidget);

        // بررسی اینکه نام ایستگاه مبدا و مقصد در لیست مسیر رندر شده باشند
        expect(find.text('تجریش'), findsWidgets);
        expect(find.text('تئاتر شهر'), findsWidgets);
      },
    );
  });
}
