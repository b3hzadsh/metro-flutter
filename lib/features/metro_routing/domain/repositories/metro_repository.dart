// مسیر: lib/features/metro_routing/domain/repositories/metro_repository.dart

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/metro_graph.dart';

abstract class MetroRepository {
  Future<Either<Failure, MetroGraph>> getMetroGraph();

  Future<Either<Failure, void>> updateMetroGraph();
}
