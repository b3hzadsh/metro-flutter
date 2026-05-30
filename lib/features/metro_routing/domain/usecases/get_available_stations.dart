// مسیر: lib/features/metro_routing/domain/usecases/get_available_stations.dart

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/metro_repository.dart';

class GetAvailableStations {
  final MetroRepository repository;

  GetAvailableStations(this.repository);

  Future<Either<Failure, List<String>>> call() async {
    final result = await repository.getMetroGraph();

    return result.map((graph) {
      // استخراج تمام مقادیر فارسی (Value ها) از دیکشنری
      final stations = graph.stationsFa.values.toList();
      // حذف موارد تکراری و مرتب‌سازی الفبایی
      final uniqueStations = stations.toSet().toList()..sort();
      return uniqueStations;
    });
  }
}
