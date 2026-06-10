import 'package:flutter_test/flutter_test.dart';
import 'package:metro/main.dart';
import 'package:metro/injection_container.dart' as di;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await di.init();
  });

  testWidgets('App title smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('مسیریاب آفلاین مترو'), findsOneWidget);
  });
}
