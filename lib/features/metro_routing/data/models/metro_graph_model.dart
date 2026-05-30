// مسیر: lib/features/metro_routing/data/models/metro_graph_model.dart

import 'dart:convert';
import 'package:objectbox/objectbox.dart';
import '../../domain/entities/metro_graph.dart';

@Entity()
class MetroGraphModel extends MetroGraph {
  @Id()
  int id;

  String nodesJson;
  String stationsFaJson; // اضافه شدن ستون دیتابیس برای اسامی فارسی

  @Property(type: PropertyType.date)
  DateTime lastUpdatedData;

  MetroGraphModel({
    this.id = 0,
    required this.nodesJson,
    required this.stationsFaJson, // اضافه شد
    required this.lastUpdatedData,
  }) : super(
         nodes: _parseNodesStr(nodesJson),
         stationsFa: _parseStationsFaStr(
           stationsFaJson,
         ), // پارس کردن دیتای فارسی
         lastUpdated: lastUpdatedData,
       );

  // تبدیل رشته JSON به Map تو در تو برای گراف
  static Map<String, Map<String, int>> _parseNodesStr(String jsonString) {
    final Map<String, dynamic> map = json.decode(jsonString);
    final Map<String, Map<String, int>> result = {};
    map.forEach((key, value) {
      result[key] = Map<String, int>.from(value as Map);
    });
    return result;
  }

  // تبدیل رشته JSON به Map ساده برای دیکشنری فارسی
  static Map<String, String> _parseStationsFaStr(String jsonString) {
    final Map<String, dynamic> map = json.decode(jsonString);
    return Map<String, String>.from(map);
  }

  factory MetroGraphModel.fromEntity(MetroGraph entity) {
    return MetroGraphModel(
      nodesJson: json.encode(entity.nodes),
      stationsFaJson: json.encode(entity.stationsFa), // آماده‌سازی برای ذخیره
      lastUpdatedData: entity.lastUpdated,
    );
  }

  factory MetroGraphModel.fromJson(Map<String, dynamic> jsonMap) {
    final Map<String, dynamic> nodesData = jsonMap['nodes'] ?? {};
    final Map<String, dynamic> stationsFaData =
        jsonMap['stationsFa'] ?? {}; // دریافت از سرور
    return MetroGraphModel(
      nodesJson: json.encode(nodesData),
      stationsFaJson: json.encode(stationsFaData),
      lastUpdatedData: DateTime.parse(jsonMap['lastUpdated'] as String),
    );
  }
}
