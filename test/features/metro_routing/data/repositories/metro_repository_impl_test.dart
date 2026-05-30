// مسیر: test/features/metro_routing/data/repositories/metro_repository_impl_test.dart

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import 'package:metro/core/error/exceptions.dart'; // مسیرها را با پروژه خودتان هماهنگ کنید
import 'package:metro/core/error/failures.dart';
import 'package:metro/features/metro_routing/data/models/metro_graph_model.dart';
import 'package:metro/features/metro_routing/data/repositories/metro_repository_impl.dart';
import 'package:metro/features/metro_routing/data/datasources/metro_remote_data_source.dart';
import 'package:metro/features/metro_routing/data/datasources/metro_local_data_source.dart';

class MockRemoteDataSource extends Mock implements MetroRemoteDataSource {}

class MockLocalDataSource extends Mock implements MetroLocalDataSource {}

class MockInternetConnectionChecker extends Mock
    implements InternetConnectionChecker {}

void main() {
  late MetroRepositoryImpl repository;
  late MockRemoteDataSource mockRemoteDataSource;
  late MockLocalDataSource mockLocalDataSource;
  late MockInternetConnectionChecker mockNetworkInfo;

  setUp(() {
    mockRemoteDataSource = MockRemoteDataSource();
    mockLocalDataSource = MockLocalDataSource();
    mockNetworkInfo = MockInternetConnectionChecker();

    repository = MetroRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      networkInfo: mockNetworkInfo,
    );
  });

  // مدل آماده برای استفاده در تمام تست‌ها
  final tMetroGraphModel = MetroGraphModel(
    id: 1,
    nodesJson: '{"Tajrish":{"Qeytarieh":2}}',
    stationsFaJson: '{"Tajrish":"تجریش"}',
    lastUpdatedData: DateTime.parse("2026-05-30T10:00:00.000Z"),
  );

  group('getMetroGraph (آفلاین کامل)', () {
    test('باید گراف را از دیتابیس محلی بخواند و برگرداند', () async {
      // Arrange
      when(
        () => mockLocalDataSource.getMetroGraph(),
      ).thenAnswer((_) async => tMetroGraphModel);

      // Act
      final result = await repository.getMetroGraph();

      // Assert
      verify(() => mockLocalDataSource.getMetroGraph());
      // مطمئن می‌شویم که برای خواندن گراف به هیچ وجه سمت سرور نمی‌رود
      verifyZeroInteractions(mockRemoteDataSource);
      expect(result, equals(Right(tMetroGraphModel)));
    });

    test(
      'وقتی دیتابیس خالی است (اجرای اول)، باید خطای CacheFailure برگرداند',
      () async {
        // Arrange
        when(
          () => mockLocalDataSource.getMetroGraph(),
        ).thenThrow(CacheException());

        // Act
        final result = await repository.getMetroGraph();

        // Assert
        expect(
          result,
          equals(
            const Left(
              CacheFailure(
                'نقشه مترو یافت نشد. لطفاً ابتدا دیتا را دانلود کنید.',
              ),
            ),
          ),
        );
      },
    );
  });

  group('updateMetroGraph (وابسته به اینترنت)', () {
    group('دستگاه آنلاین است', () {
      setUp(() {
        when(() => mockNetworkInfo.hasConnection).thenAnswer((_) async => true);
      });

      test(
        'باید گراف را از سرور دانلود کرده، در دیتابیس کش کند و Right برگرداند',
        () async {
          // Arrange
          when(
            () => mockRemoteDataSource.downloadGraph(),
          ).thenAnswer((_) async => tMetroGraphModel);

          when(
            () => mockLocalDataSource.cacheMetroGraph(tMetroGraphModel),
          ).thenAnswer((_) async => Future<void>.value());

          // Act
          final result = await repository.updateMetroGraph();

          // Assert
          verify(() => mockRemoteDataSource.downloadGraph());
          verify(() => mockLocalDataSource.cacheMetroGraph(tMetroGraphModel));
          // موفقیت در dartz با متد Right(null) برای توابع بدون خروجی نشان داده می‌شود
          expect(result, equals(const Right(null)));
        },
      );

      test(
        'وقتی سرور ارور میدهد (مثلا ۴۰۴)، باید خطای RoutingFailure برگرداند',
        () async {
          // Arrange
          when(
            () => mockRemoteDataSource.downloadGraph(),
          ).thenThrow(ServerException());

          // Act
          final result = await repository.updateMetroGraph();

          // Assert
          verify(() => mockRemoteDataSource.downloadGraph());
          // نباید تلاشی برای ذخیره دیتای نامعتبر انجام شود
          verifyNever(() => mockLocalDataSource.cacheMetroGraph(any()));
          expect(
            result,
            equals(
              const Left(RoutingFailure('خطا در دریافت اطلاعات از سرور.')),
            ),
          );
        },
      );
    });

    group('دستگاه آفلاین است', () {
      setUp(() {
        when(
          () => mockNetworkInfo.hasConnection,
        ).thenAnswer((_) async => false);
      });

      test(
        'باید بدون تلاش برای اتصال به سرور، خطای عدم دسترسی به اینترنت برگرداند',
        () async {
          // Act
          final result = await repository.updateMetroGraph();

          // Assert
          verifyZeroInteractions(mockRemoteDataSource);
          expect(
            result,
            equals(
              const Left(
                RoutingFailure('برای آپدیت نقشه به اینترنت نیاز دارید.'),
              ),
            ),
          );
        },
      );
    });
  });
}
