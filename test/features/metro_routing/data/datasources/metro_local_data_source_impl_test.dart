// مسیر: test/features/metro_routing/data/datasources/metro_local_data_source_impl_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:objectbox/objectbox.dart';

import 'package:metro/core/error/exceptions.dart';
import 'package:metro/features/metro_routing/data/models/metro_graph_model.dart';
import 'package:metro/features/metro_routing/data/datasources/metro_local_data_source.dart';

// شبیه‌سازی Box اختصاصی ObjectBox
class MockBox extends Mock implements Box<MetroGraphModel> {}

void main() {
  late MetroLocalDataSourceImpl dataSource;
  late MockBox mockBox;

  setUp(() {
    mockBox = MockBox();
    dataSource = MetroLocalDataSourceImpl(store: mockBox);

    // ثبت کلاس MetroGraphModel به عنوان یک نوع مجاز (Fallback) در Mocktail
    registerFallbackValue(
      MetroGraphModel(
        id: 1,
        nodesJson: '{}',
        stationsFaJson: '{}',
        lastUpdatedData: DateTime.now(),
      ),
    );
  });

  // مدل آماده برای تست
  final tMetroGraphModel = MetroGraphModel(
    id: 1,
    nodesJson: '{"Tajrish":{"Qeytarieh":2}}',
    stationsFaJson: '{"Tajrish":"تجریش"}',
    lastUpdatedData: DateTime.parse("2026-05-30T10:00:00.000Z"),
  );

  group('getMetroGraph', () {
    test('should return MetroGraphModel when it exists in ObjectBox', () async {
      // Arrange
      // متد get در ObjectBox نیازی به async ندارد
      when(() => mockBox.get(1)).thenReturn(tMetroGraphModel);

      // Act
      final result = await dataSource.getMetroGraph();

      // Assert
      verify(() => mockBox.get(1));
      expect(result, equals(tMetroGraphModel));
    });

    test(
      'should throw CacheException when there is no data in ObjectBox',
      () async {
        // Arrange
        when(() => mockBox.get(1)).thenReturn(null); // حالت خالی بودن دیتابیس

        // Act & Assert
        expect(
          () => dataSource.getMetroGraph(),
          throwsA(isA<CacheException>()),
        );
      },
    );
  });

  group('cacheMetroGraph', () {
    test('should call Box.put to save the graph data', () async {
      // Arrange
      // متد put یک int (آیدی ذخیره شده) برمی‌گرداند
      when(() => mockBox.put(any())).thenReturn(1);

      // Act
      await dataSource.cacheMetroGraph(tMetroGraphModel);

      // Assert
      // تایید اینکه متد put با مدلی که آیدی آن ۱ است فراخوانی شده باشد
      verify(() => mockBox.put(any(that: isA<MetroGraphModel>())));
    });
  });
}
