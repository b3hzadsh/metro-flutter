// مسیر: test/features/metro_routing/domain/usecases/get_metro_route_test.dart

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:metro/core/error/failures.dart'; // مسیرها را با پروژه خودتان هماهنگ کنید
import 'package:metro/features/metro_routing/domain/entities/metro_graph.dart';
import 'package:metro/features/metro_routing/domain/entities/metro_route.dart';
import 'package:metro/features/metro_routing/domain/repositories/metro_repository.dart';
import 'package:metro/features/metro_routing/domain/usecases/get_metro_route.dart';

class MockMetroRepository extends Mock implements MetroRepository {}

void main() {
  late GetMetroRoute usecase;
  late MockMetroRepository mockMetroRepository;

  setUp(() {
    mockMetroRepository = MockMetroRepository();
    usecase = GetMetroRoute(mockMetroRepository);
  });

  // ==========================================
  // ساخت یک گراف تستی برای به چالش کشیدن دایجسترا
  // ==========================================
  final tMetroGraph = MetroGraph(
    nodes: {
      'Station_A': {
        'Station_B': 2,
        'Station_C': 10,
      }, // مسیر مستقیم به C ده دقیقه زمان می‌برد
      'Station_B': {
        'Station_A': 2,
        'Station_C': 3,
      }, // مسیر غیرمستقیم به C فقط ۵ دقیقه (۲+۳) زمان می‌برد
      'Station_C': {'Station_B': 3, 'Station_A': 10},
      'Station_Isolated':
          {}, // ایستگاهی که به هیچ‌جا وصل نیست (برای تست عدم وجود مسیر)
    },
    stationsFa: {
      'Station_A': 'ایستگاه الف',
      'Station_B': 'ایستگاه ب',
      'Station_C': 'ایستگاه ج',
    },
    lastUpdated: DateTime.parse("2026-05-30T10:00:00.000Z"),
  );

  group('GetMetroRoute UseCase (Dijkstra Algorithm)', () {
    test(
      'باید مسیر سریع‌تر (غیرمستقیم) را با ورودی کلیدهای انگلیسی پیدا کند و نام‌های فارسی برگرداند',
      () async {
        // Arrange
        when(
          () => mockMetroRepository.getMetroGraph(),
        ).thenAnswer((_) async => Right(tMetroGraph));

        // Act
        // دایجسترا باید مسیر A -> B -> C (۵ دقیقه) را به جای A -> C (۱۰ دقیقه) انتخاب کند
        final result = await usecase(
          startStation: 'Station_A',
          endStation: 'Station_C',
        );

        // Assert
        expect(
          result,
          equals(
            const Right(
              MetroRoute(
                path: [
                  'ایستگاه الف',
                  'ایستگاه ب',
                  'ایستگاه ج',
                ], // خروجی باید ترجمه شده باشد
                estimatedTimeMinutes: 5,
              ),
            ),
          ),
        );
        verify(() => mockMetroRepository.getMetroGraph());
        verifyNoMoreInteractions(mockMetroRepository);
      },
    );

    test(
      'سیستم Reverse Lookup باید ورودی فارسی را تشخیص دهد و مسیر را به درستی محاسبه کند',
      () async {
        // Arrange
        when(
          () => mockMetroRepository.getMetroGraph(),
        ).thenAnswer((_) async => Right(tMetroGraph));

        // Act
        // کاربر نام‌ها را به فارسی تایپ کرده است
        final result = await usecase(
          startStation: 'ایستگاه الف',
          endStation: 'ایستگاه ج',
        );

        // Assert
        expect(
          result,
          equals(
            const Right(
              MetroRoute(
                path: ['ایستگاه الف', 'ایستگاه ب', 'ایستگاه ج'],
                estimatedTimeMinutes: 5,
              ),
            ),
          ),
        );
      },
    );

    test(
      'اگر ایستگاه مبدا یا مقصد در دیتابیس وجود نداشته باشد، باید خطای RoutingFailure برگرداند',
      () async {
        // Arrange
        when(
          () => mockMetroRepository.getMetroGraph(),
        ).thenAnswer((_) async => Right(tMetroGraph));

        // Act
        // نام ایستگاه اشتباه تایپ شده است
        final result = await usecase(
          startStation: 'ایستگاه نامعلوم',
          endStation: 'Station_C',
        );

        // Assert
        expect(
          result,
          equals(
            const Left(
              RoutingFailure(
                'ایستگاه مبدا یا مقصد در نقشه یافت نشد. املای آن را بررسی کنید.',
              ),
            ),
          ),
        );
      },
    );

    test(
      'اگر بین دو ایستگاه هیچ مسیر اتصالی وجود نداشته باشد، باید خطای RoutingFailure برگرداند',
      () async {
        // Arrange
        when(
          () => mockMetroRepository.getMetroGraph(),
        ).thenAnswer((_) async => Right(tMetroGraph));

        // Act
        // تلاش برای رسیدن به ایستگاه ایزوله
        final result = await usecase(
          startStation: 'Station_A',
          endStation: 'Station_Isolated',
        );

        // Assert
        expect(
          result,
          equals(
            const Left(RoutingFailure('مسیری بین این دو ایستگاه یافت نشد.')),
          ),
        );
      },
    );

    test(
      'وقتی ریپازیتوری ارور میدهد (مثلا گراف پیدا نشد)، باید همان ارور را بدون اجرای دایجسترا برگرداند',
      () async {
        // Arrange
        when(
          () => mockMetroRepository.getMetroGraph(),
        ).thenAnswer((_) async => const Left(CacheFailure('دیتا یافت نشد.')));

        // Act
        final result = await usecase(
          startStation: 'Station_A',
          endStation: 'Station_C',
        );

        // Assert
        expect(result, equals(const Left(CacheFailure('دیتا یافت نشد.'))));
      },
    );
  });
}
