// مسیر: test/features/metro_routing/presentation/bloc/metro_routing_bloc_test.dart

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:metro/core/error/failures.dart'; // مسیرها را با پروژه خودتان هماهنگ کنید
import 'package:metro/features/metro_routing/domain/entities/metro_route.dart';
import 'package:metro/features/metro_routing/domain/usecases/get_metro_route.dart';
import 'package:metro/features/metro_routing/domain/usecases/update_metro_graph.dart';
import 'package:metro/features/metro_routing/presentation/bloc/metro_routing_bloc.dart';
import 'package:metro/features/metro_routing/presentation/bloc/metro_routing_event.dart';
import 'package:metro/features/metro_routing/presentation/bloc/metro_routing_state.dart';

// شبیه‌سازی UseCaseهای لایه Domain
class MockGetMetroRoute extends Mock implements GetMetroRoute {}

class MockUpdateMetroGraph extends Mock implements UpdateMetroGraph {}

void main() {
  late MetroRoutingBloc bloc;
  late MockGetMetroRoute mockGetMetroRoute;
  late MockUpdateMetroGraph mockUpdateMetroGraph;

  setUp(() {
    mockGetMetroRoute = MockGetMetroRoute();
    mockUpdateMetroGraph = MockUpdateMetroGraph();

    // تزریق Mockها به BLoC اصلی
    bloc = MetroRoutingBloc(
      getOfflineMetroRoute: mockGetMetroRoute,
      updateMetroGraph: mockUpdateMetroGraph,
    );
  });

  // ==========================================
  // متغیرهای مشترک برای استفاده در تست‌ها
  // ==========================================
  const tStartStation = 'تجریش';
  const tEndStation = 'تئاتر شهر';
  const tRoute = MetroRoute(
    path: ['تجریش', 'قیطریه', 'شهید صدر', 'تئاتر شهر'],
    estimatedTimeMinutes: 25,
  );
  const tErrorMessage = 'خطای ارتباط با سرور';

  // پاکسازی بعد از هر تست (بستن BLoC)
  tearDown(() {
    bloc.close();
  });

  test('وضعیت اولیه BLoC باید MetroRoutingInitial باشد', () {
    expect(bloc.state, equals(MetroRoutingInitial()));
  });

  // ==========================================
  // گروه تست‌های رویداد آپدیت نقشه (UpdateGraphRequested)
  // ==========================================
  group('UpdateGraphRequested', () {
    blocTest<MetroRoutingBloc, MetroRoutingState>(
      'وقتی آپدیت موفقیت‌آمیز است، باید وضعیت‌های [GraphUpdating, GraphUpdateSuccess] را منتشر کند',
      build: () {
        // Arrange: شبیه‌سازی موفقیت یوزکیس (Right برمی‌گرداند)
        when(
          () => mockUpdateMetroGraph(),
        ).thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (bloc) =>
          bloc.add(UpdateGraphRequested()), // کاربر دکمه آپدیت را می‌زند
      expect: () => [GraphUpdating(), const GraphUpdateSuccess()],
      verify: (_) {
        // بررسی اینکه یوزکیس حتماً صدا زده شده باشد
        verify(() => mockUpdateMetroGraph()).called(1);
      },
    );

    blocTest<MetroRoutingBloc, MetroRoutingState>(
      'وقتی آپدیت با خطا مواجه می‌شود، باید وضعیت‌های [GraphUpdating, MetroRoutingError] را منتشر کند',
      build: () {
        // Arrange: شبیه‌سازی شکست یوزکیس (Left برمی‌گرداند)
        when(
          () => mockUpdateMetroGraph(),
        ).thenAnswer((_) async => const Left(RoutingFailure(tErrorMessage)));
        return bloc;
      },
      act: (bloc) => bloc.add(UpdateGraphRequested()),
      expect: () => [
        GraphUpdating(),
        const MetroRoutingError(message: tErrorMessage),
      ],
    );
  });

  // ==========================================
  // گروه تست‌های رویداد مسیریابی آفلاین (GetOfflineRouteRequested)
  // ==========================================
  group('GetOfflineRouteRequested', () {
    blocTest<MetroRoutingBloc, MetroRoutingState>(
      'وقتی مسیریابی موفق است، باید وضعیت‌های [RouteLoading, RouteLoaded] را منتشر کند',
      build: () {
        // Arrange: شبیه‌سازی موفقیت الگوریتم دایجسترا
        when(
          () => mockGetMetroRoute(
            startStation: any(named: 'startStation'),
            endStation: any(named: 'endStation'),
          ),
        ).thenAnswer((_) async => const Right(tRoute));
        return bloc;
      },
      act: (bloc) => bloc.add(
        const GetOfflineRouteRequested(
          startStation: tStartStation,
          endStation: tEndStation,
        ),
      ),
      expect: () => [RouteLoading(), const RouteLoaded(route: tRoute)],
      verify: (_) {
        verify(
          () => mockGetMetroRoute(
            startStation: tStartStation,
            endStation: tEndStation,
          ),
        ).called(1);
      },
    );

    blocTest<MetroRoutingBloc, MetroRoutingState>(
      'وقتی ایستگاه یافت نمی‌شود یا خطایی رخ می‌دهد، باید وضعیت‌های [RouteLoading, MetroRoutingError] را منتشر کند',
      build: () {
        // Arrange: شبیه‌سازی شکست (مثلاً کاربر اسم ایستگاه را اشتباه تایپ کرده)
        when(
          () => mockGetMetroRoute(
            startStation: any(named: 'startStation'),
            endStation: any(named: 'endStation'),
          ),
        ).thenAnswer((_) async => const Left(RoutingFailure(tErrorMessage)));
        return bloc;
      },
      act: (bloc) => bloc.add(
        const GetOfflineRouteRequested(
          startStation: tStartStation,
          endStation: tEndStation,
        ),
      ),
      expect: () => [
        RouteLoading(),
        const MetroRoutingError(message: tErrorMessage),
      ],
    );
  });
}
