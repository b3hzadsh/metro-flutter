// مسیر: test/features/metro_routing/data/models/metro_route_model_test.dart

import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:metro/features/metro_routing/data/models/metro_route_model.dart';
import 'package:metro/features/metro_routing/domain/entities/metro_route.dart';
import '../../../../fixtures/fixture_reader.dart'; // فایل کمکی برای خواندن فایل json

void main() {
  const tMetroRouteModel = MetroRouteModel(
    path: ['Tajrish', 'Gheytarieh', 'Kahrizak'],
    estimatedTimeMinutes: 60,
  );

  test('should be a subclass of MetroRoute entity', () async {
    // Assert: تایید اینکه مدل، همان انتیتی با امکانات بیشتر است
    expect(tMetroRouteModel, isA<MetroRoute>());
  });

  group('fromJson', () {
    test('should return a valid model when the JSON is parsed', () async {
      // Arrange: خواندن فایل متنی و تبدیل آن به Map
      final Map<String, dynamic> jsonMap = json.decode(
        fixture('metro_route.json'),
      );

      // Act: فراخوانی متد از مدل
      final result = MetroRouteModel.fromJson(jsonMap);

      // Assert: بررسی مطابقت نتیجه با مدل مورد انتظار
      expect(result, tMetroRouteModel);
    });
  });
}
