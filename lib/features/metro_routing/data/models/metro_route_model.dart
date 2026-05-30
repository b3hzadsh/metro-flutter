// مسیر: lib/features/metro_routing/data/models/metro_route_model.dart

import '../../domain/entities/metro_route.dart';

class MetroRouteModel extends MetroRoute {
  const MetroRouteModel({
    required super.path,
    required super.estimatedTimeMinutes,
  });

  // تبدیل نقشه (Map) دریافتی از JSON به یک شیء مدل
  factory MetroRouteModel.fromJson(Map<String, dynamic> json) {
    return MetroRouteModel(
      // تبدیل ایمن لیست داینامیک به لیست رشته‌ها
      path: List<String>.from(json['path'] ?? []),
      // تبدیل ایمن اعداد (جلوگیری از خطای int و double)
      estimatedTimeMinutes: (json['estimatedTimeMinutes'] as num).toInt(),
    );
  }

  // تبدیل شیء مدل به نقشه (برای ارسال به سرور یا ذخیره محلی در آینده)
  Map<String, dynamic> toJson() {
    return {'path': path, 'estimatedTimeMinutes': estimatedTimeMinutes};
  }
}
