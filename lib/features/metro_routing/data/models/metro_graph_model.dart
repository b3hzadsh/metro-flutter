// مسیر: lib/features/metro_routing/data/models/metro_graph_model.dart

import 'dart:convert';
import 'package:objectbox/objectbox.dart';

@Entity()
class MetroGraphModel {
  @Id()
  int id = 0;

  String lastUpdated;
  String nodesJson;
  String stationsFaJson;

  String stationsLinesJson;

  MetroGraphModel({
    this.id = 0,
    required this.lastUpdated,
    required this.nodesJson,
    required this.stationsFaJson,
    required this.stationsLinesJson,
  });

  Map<String, Map<String, int>> get nodes {
    final Map<String, dynamic> decoded = json.decode(nodesJson);
    return decoded.map((key, value) {
      final innerMap = value as Map<String, dynamic>;
      return MapEntry(key, innerMap.map((k, v) => MapEntry(k, v as int)));
    });
  }

  Map<String, String> get stationsFa {
    final Map<String, dynamic> decoded = json.decode(stationsFaJson);
    return decoded.map((key, value) => MapEntry(key, value.toString()));
  }

  Map<String, List<int>> get stationsLines {
    final Map<String, dynamic> decoded = json.decode(stationsLinesJson);
    return decoded.map((key, value) {
      final linesList = (value as List<dynamic>).map((e) => e as int).toList();
      return MapEntry(key, linesList);
    });
  }

  factory MetroGraphModel.fromJson(Map<String, dynamic> jsonMap) {
    return MetroGraphModel(
      lastUpdated: jsonMap['lastUpdated'] ?? '',
      nodesJson: json.encode(jsonMap['nodes'] ?? {}),
      stationsFaJson: json.encode(jsonMap['stationsFa'] ?? {}),
      stationsLinesJson: json.encode(jsonMap['stationsLines'] ?? {}),
    );
  }
}
