// مسیر: lib/features/metro_routing/data/repositories/metro_repository_impl.dart

import 'package:dartz/dartz.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/metro_graph.dart';
import '../../domain/repositories/metro_repository.dart';
import '../datasources/metro_remote_data_source.dart';
import '../datasources/metro_local_data_source.dart';

class MetroRepositoryImpl implements MetroRepository {
  final MetroRemoteDataSource remoteDataSource;
  final MetroLocalDataSource localDataSource;
  final InternetConnectionChecker networkInfo;

  MetroRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, MetroGraph>> getMetroGraph() async {
    try {
      final localGraphModel = await localDataSource.getLastMetroGraph();

      final metroGraph = MetroGraph(
        nodes: localGraphModel.nodes,
        stationsFa: localGraphModel.stationsFa,
        stationsLines: localGraphModel.stationsLines,
        lastUpdated:
            DateTime.tryParse(localGraphModel.lastUpdated) ?? DateTime.now(),
      );

      return Right(metroGraph);
    } catch (e) {
      return const Left(CacheFailure('خطا در خواندن اطلاعات محلی'));
    }
  }

  @override
  Future<Either<Failure, void>> updateMetroGraph() async {
    // DEBUG log removed
    if (await networkInfo.hasConnection) {
      try {
        // DEBUG log removed
        final remoteMetroGraph = await remoteDataSource.downloadGraph();

        // DEBUG log removed
        await localDataSource.cacheMetroGraph(remoteMetroGraph);

        // DEBUG log removed
        return const Right(null);
      } on ServerException {
        return const Left(RoutingFailure('خطا در دریافت اطلاعات از سرور.'));
      } catch (e) {
        // FATAL log removed
        return const Left(RoutingFailure('خطای داخلی در پردازش اطلاعات.'));
      }
    } else {
      // DEBUG log removed
      return const Left(
        RoutingFailure('برای آپدیت نقشه به اینترنت نیاز دارید.'),
      );
    }
  }
}
