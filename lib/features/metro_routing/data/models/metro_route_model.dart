// مسیر: lib/features/metro_routing/data/models/metro_route_model.dart

import '../../domain/entities/metro_route.dart';

class MetroRouteModel extends MetroRoute {
  const MetroRouteModel({
    required super.legs,
    required super.estimatedTimeMinutes,
  });

  /// در صورتی که در آینده بخواهید مسیرهای جستجوشده را در تاریخچه (History) گوشی
  /// ذخیره کنید، این متدها برای تبدیل مدل به JSON و برعکس بسیار مفید خواهند بود.

  factory MetroRouteModel.fromJson(Map<String, dynamic> json) {
    return MetroRouteModel(
      legs: (json['legs'] as List<dynamic>)
          .map(
            (legJson) =>
                RouteLegModel.fromJson(legJson as Map<String, dynamic>),
          )
          .toList(),
      estimatedTimeMinutes: json['estimatedTimeMinutes'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'legs': legs.map((leg) {
        return {'line': leg.line, 'stationsFa': leg.stationsFa};
      }).toList(),
      'estimatedTimeMinutes': estimatedTimeMinutes,
    };
  }
}

/// مدل کمکی برای بخش‌های سفر (RouteLeg) جهت سریالایز کردن
class RouteLegModel extends RouteLeg {
  const RouteLegModel({required super.line, required super.stationsFa});

  factory RouteLegModel.fromJson(Map<String, dynamic> json) {
    return RouteLegModel(
      line: json['line'] as int,
      stationsFa: List<String>.from(json['stationsFa'] as List),
    );
  }
}
