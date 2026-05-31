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
    print('🔵 DEBUG [Repository]: بررسی اتصال اینترنت...');
    if (await networkInfo.hasConnection) {
      try {
        print('🔵 DEBUG [Repository]: دستگاه آنلاین است. فراخوانی دانلود...');
        final remoteMetroGraph = await remoteDataSource.downloadGraph();

        print(
          '🔵 DEBUG [Repository]: دانلود موفق. تلاش برای کش در ObjectBox...',
        );
        await localDataSource.cacheMetroGraph(remoteMetroGraph);

        print('🟢 DEBUG [Repository]: کش کردن در دیتابیس با موفقیت انجام شد!');
        return const Right(null);
      } on ServerException {
        return const Left(RoutingFailure('خطا در دریافت اطلاعات از سرور.'));
      } catch (e) {
        print('🔴 FATAL [Repository ObjectBox Error]: خطا در ذخیره‌سازی محلی.');
        print('خطا: $e');
        return const Left(RoutingFailure('خطای داخلی در پردازش اطلاعات.'));
      }
    } else {
      print('🔴 DEBUG [Repository]: دستگاه آفلاین است.');
      return const Left(
        RoutingFailure('برای آپدیت نقشه به اینترنت نیاز دارید.'),
      );
    }
  }
}
