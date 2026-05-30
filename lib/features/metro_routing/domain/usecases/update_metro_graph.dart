// مسیر: lib/features/metro_routing/domain/usecases/update_metro_graph.dart

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/metro_repository.dart';

class UpdateMetroGraph {
  final MetroRepository repository;

  UpdateMetroGraph(this.repository);

  // چون نیازی به ورودی خاصی از سمت کاربر (مثل نام ایستگاه) نداریم، متد پارامتری نمی‌گیرد
  Future<Either<Failure, void>> call() async {
    return await repository.updateMetroGraph();
  }
}
