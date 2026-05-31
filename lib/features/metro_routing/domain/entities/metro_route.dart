// مسیر: lib/features/metro_routing/domain/entities/metro_route.dart

import 'package:equatable/equatable.dart';

class RouteLeg extends Equatable {
  final int line;
  final List<String> stationsFa;

  const RouteLeg({required this.line, required this.stationsFa});

  @override
  List<Object> get props => [line, stationsFa];
}

class MetroRoute extends Equatable {
  final List<RouteLeg> legs; 
  final int estimatedTimeMinutes;

  const MetroRoute({required this.legs, required this.estimatedTimeMinutes});

  @override
  List<Object> get props => [legs, estimatedTimeMinutes];
}
