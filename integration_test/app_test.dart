// مسیر: integration_test/app_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:metro/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Metro Routing App E2E Test', () {
    testWidgets(
      'باید نقشه را دانلود کند، مسیر را محاسبه کند و نتیجه را روی صفحه نشان دهد',
      (WidgetTester tester) async {
        app.main();
        await tester.pumpAndSettle();
        final updateButton = find.byIcon(Icons.cloud_download_outlined);
        expect(updateButton, findsOneWidget);
        await tester.tap(updateButton);
        await tester.pumpAndSettle(const Duration(seconds: 5));
        final startInput = find.widgetWithText(
          TextField,
          'ایستگاه مبدا (مثال: تجریش)',
        );
        final endInput = find.widgetWithText(
          TextField,
          'ایستگاه مقصد (مثال: دروازه دولت)',
        );
        await tester.enterText(startInput, 'تجریش');
        await tester.enterText(endInput, 'تئاتر شهر');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();
        final routeButton = find.text('محاسبه مسیر');
        await tester.tap(routeButton);
        await tester.pumpAndSettle();
        expect(find.textContaining('زمان تخمینی:'), findsOneWidget);

        expect(find.text('تجریش'), findsWidgets);
        expect(find.text('تئاتر شهر'), findsWidgets);
      },
    );
  });
}
