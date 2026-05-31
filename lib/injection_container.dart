// مسیر: lib/injection_container.dart

import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import 'features/metro_routing/domain/usecases/get_available_stations.dart';
import 'objectbox.g.dart';

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
  final store = await openStore();

  sl.registerLazySingleton<Store>(() => store);

  sl.registerLazySingleton<Box<MetroGraphModel>>(
    () => store.box<MetroGraphModel>(),
  );

  sl.registerFactory(
    () => MetroRoutingBloc(
      getOfflineMetroRoute: sl(),
      updateMetroGraph: sl(),
      getAvailableStations: sl(),
    ),
  );

  sl.registerLazySingleton(() => GetMetroRoute(sl()));
  sl.registerLazySingleton(() => UpdateMetroGraph(sl()));
  sl.registerLazySingleton(() => GetAvailableStations(sl()));

  sl.registerLazySingleton<MetroRepository>(
    () => MetroRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerLazySingleton<MetroRemoteDataSource>(
    () => MetroRemoteDataSourceImpl(dio: sl()),
  );

  sl.registerLazySingleton<MetroLocalDataSource>(
    () => MetroLocalDataSourceImpl(store: sl()),
  );

  sl.registerLazySingleton(() => Dio());

  sl.registerLazySingleton(() => InternetConnectionChecker.createInstance());
}
