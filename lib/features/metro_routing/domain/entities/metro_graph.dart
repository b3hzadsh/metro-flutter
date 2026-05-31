// مسیر: lib/features/metro_routing/domain/entities/metro_graph.dart

import 'package:equatable/equatable.dart';

class MetroGraph extends Equatable {
  final Map<String, Map<String, int>> nodes;
  final Map<String, String> stationsFa;
  final DateTime lastUpdated;
  final Map<String, List<int>> stationsLines;

  const MetroGraph({
    required this.stationsLines,
    required this.nodes,
    required this.stationsFa,
    required this.lastUpdated,
  });

  @override
  List<Object?> get props => [nodes, stationsFa, lastUpdated];
}
