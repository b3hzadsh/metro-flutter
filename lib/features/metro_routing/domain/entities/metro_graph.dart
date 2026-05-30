// مسیر: lib/features/metro_routing/domain/entities/metro_graph.dart

import 'package:equatable/equatable.dart';

class MetroGraph extends Equatable {
  final Map<String, Map<String, int>> nodes;
  final Map<String, String> stationsFa; // اضافه شدن دیکشنری فارسی
  final DateTime lastUpdated;

  const MetroGraph({
    required this.nodes,
    required this.stationsFa, // اضافه شد
    required this.lastUpdated,
  });

  @override
  List<Object?> get props => [nodes, stationsFa, lastUpdated];
}
