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
      // فقط از دیتابیس لوکال می‌خواند (کاملاً آفلاین)
      final localGraph = await localDataSource.getMetroGraph();
      return Right(localGraph);
    } on CacheException {
      // اگر دیتابیس خالی بود (اجرای اول برنامه)
      return const Left(
        CacheFailure('نقشه مترو یافت نشد. لطفاً ابتدا دیتا را دانلود کنید.'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> updateMetroGraph() async {
    // ۱. بررسی اتصال اینترنت
    if (await networkInfo.hasConnection) {
      try {
        // ۲. دریافت گراف جدید از سرور
        // (فرض میکنیم متدی به نام downloadGraph به MetroRemoteDataSource اضافه کرده‌ایم)
        final remoteGraph = await remoteDataSource.downloadGraph();

        // ۳. ذخیره در ObjectBox
        await localDataSource.cacheMetroGraph(remoteGraph);

        // موفقیت (خروجی خاصی نیاز نیست، پس Right(null) یا Right(unit) در dartz)
        return const Right(null);
      } on ServerException {
        return const Left(RoutingFailure('خطا در دریافت اطلاعات از سرور.'));
      }
    } else {
      return const Left(
        RoutingFailure('برای آپدیت نقشه به اینترنت نیاز دارید.'),
      );
    }
  }
}
