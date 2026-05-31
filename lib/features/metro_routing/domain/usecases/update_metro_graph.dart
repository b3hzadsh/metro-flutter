// مسیر: lib/features/metro_routing/domain/usecases/update_metro_graph.dart

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/metro_repository.dart';

class UpdateMetroGraph {
  final MetroRepository repository;
  UpdateMetroGraph(this.repository);
  Future<Either<Failure, void>> call() async {
    return await repository.updateMetroGraph();
  }
}
