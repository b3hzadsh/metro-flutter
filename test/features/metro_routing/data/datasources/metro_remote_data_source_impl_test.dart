// مسیر: test/features/metro_routing/data/datasources/metro_remote_data_source_impl_test.dart

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:metro/core/error/exceptions.dart'; // مسیرها را بر اساس نام پروژه خود تنظیم کنید
import 'package:metro/features/metro_routing/data/models/metro_graph_model.dart';
import 'package:metro/features/metro_routing/data/datasources/metro_remote_data_source.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MetroRemoteDataSourceImpl dataSource;
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
    dataSource = MetroRemoteDataSourceImpl(dio: mockDio);
  });

  group('downloadGraph', () {
    // یک داده JSON فرضی (Mock) برای شبیه‌سازی پاسخ سرور
    final tJsonResponse = {
      "lastUpdated": "2026-05-30T10:00:00.000Z",
      "nodes": {
        "Tajrish": {"Qeytarieh": 2},
      },
      "stationsFa": {"Tajrish": "تجریش", "Qeytarieh": "قیطریه"},
    };

    final tMetroGraphModel = MetroGraphModel.fromJson(tJsonResponse);

    test(
      'should return MetroGraphModel when the response code is 200 (success)',
      () async {
        // Arrange
        when(
          () => mockDio.get(any(), options: any(named: 'options')),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data:
                tJsonResponse, // Dio به صورت خودکار JSON را به Map تبدیل می‌کند
            statusCode: 200,
          ),
        );

        // Act
        final result = await dataSource.downloadGraph();

        // Assert
        expect(result, equals(tMetroGraphModel));
      },
    );

    test(
      'should throw a ServerException when the response code is 404 or other',
      () async {
        // Arrange
        when(
          () => mockDio.get(any(), options: any(named: 'options')),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: 'Not Found',
            statusCode: 404,
          ),
        );

        // Act & Assert
        expect(
          () => dataSource.downloadGraph(),
          throwsA(isA<ServerException>()),
        );
      },
    );
  });
}
