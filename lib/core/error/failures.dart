// مسیر کلاس خطا: lib/core/error/failures.dart
import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

class RoutingFailure extends Failure {
  const RoutingFailure(super.message);
}
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}