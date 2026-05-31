// مسیر: lib/injection_container.dart

import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

// فایل تولید شده توسط ObjectBox (نام این فایل ثابت است)
import 'features/metro_routing/domain/usecases/get_available_stations.dart';
import 'objectbox.g.dart';

// ایمپورت‌های پروژه
import 'features/metro_routing/data/datasources/metro_local_data_source.dart';
import 'features/metro_routing/data/datasources/metro_remote_data_source.dart';
import 'features/metro_routing/data/models/metro_graph_model.dart';
import 'features/metro_routing/data/repositories/metro_repository_impl.dart';
import 'features/metro_routing/domain/repositories/metro_repository.dart';
import 'features/metro_routing/domain/usecases/get_metro_route.dart';
import 'features/metro_routing/presentation/bloc/metro_routing_bloc.dart';
import 'features/metro_routing/domain/usecases/update_metro_graph.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ==========================================
  // ۱. راه‌اندازی پایگاه داده آفلاین (ObjectBox)
  // ==========================================

  // متد openStore به صورت خودکار توسط ObjectBox تولید شده است
  final store = await openStore();

  // ثبت Store اصلی دیتابیس در حافظه
  sl.registerLazySingleton<Store>(() => store);

  // اختصاص دادن یک Box (صندوقچه) برای مدل گراف و ثبت آن برای دیتاسورس
  sl.registerLazySingleton<Box<MetroGraphModel>>(
    () => store.box<MetroGraphModel>(),
  );

  // ==========================================
  // ۲. ویژگی‌ها (Features) - مسیر یابی مترو
  // ==========================================

  // --- BLoC ---
  sl.registerFactory(
    () => MetroRoutingBloc(
      getOfflineMetroRoute: sl(),
      updateMetroGraph: sl(),
      getAvailableStations: sl(), // <--- اضافه شد
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetMetroRoute(sl()));
  sl.registerLazySingleton(() => UpdateMetroGraph(sl()));
  sl.registerLazySingleton(() => GetAvailableStations(sl())); // <--- اضافه شد
  // نکته: یوزکیس UpdateMetroGraph را پس از ساخت، در اینجا اضافه خواهیم کرد

  // Repository
  sl.registerLazySingleton<MetroRepository>(
    () => MetroRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data Sources
  sl.registerLazySingleton<MetroRemoteDataSource>(
    () => MetroRemoteDataSourceImpl(dio: sl()),
  );

  // توجه کنید که Box از طریق Service Locator (sl) به دیتاسورس تزریق می‌شود
sl.registerLazySingleton<MetroLocalDataSource>(
    () => MetroLocalDataSourceImpl(store: sl()), // کلمه graphBox به store تغییر کرد
  );

  // ==========================================
  // ۳. هسته (Core) و پکیج‌های خارجی (External)
  // ==========================================

  // کلاینت شبکه (Dio)
  sl.registerLazySingleton(() => Dio());

  // بررسی وضعیت اتصال اینترنت
  sl.registerLazySingleton(() => InternetConnectionChecker.createInstance());
}
