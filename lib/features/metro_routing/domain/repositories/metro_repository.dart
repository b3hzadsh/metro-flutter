// مسیر: lib/features/metro_routing/domain/repositories/metro_repository.dart

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/metro_graph.dart';

// فقط و فقط قرارداد ریپازیتوری باید در این فایل باشد
abstract class MetroRepository {
  /// خواندن کل گراف از دیتابیس محلی (ObjectBox) برای پردازش آفلاین
  Future<Either<Failure, MetroGraph>> getMetroGraph();

  /// اتصال به سرور، دریافت آخرین گراف و ذخیره (Overwrite) در دیتابیس محلی
  Future<Either<Failure, void>> updateMetroGraph();
}
