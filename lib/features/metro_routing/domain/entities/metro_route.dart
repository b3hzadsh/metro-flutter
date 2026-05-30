// مسیر: lib/features/metro_routing/domain/entities/metro_route.dart

import 'package:equatable/equatable.dart';

class MetroRoute extends Equatable {
  final List<String> path;
  final int estimatedTimeMinutes;

  const MetroRoute({required this.path, required this.estimatedTimeMinutes});

  @override
  List<Object?> get props => [path, estimatedTimeMinutes];
}
