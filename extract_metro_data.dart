import 'dart:convert';
import 'dart:io';
import 'dart:math';

Future<void> main() async {
  const url =
      'https://github.com/mostafa-kheibary/tehran-metro-data/raw/refs/heads/main/data/stations.json';

  print('در حال دریافت فایل JSON از سرور...');

  try {
    final client = HttpClient();
    final request = await client.getUrl(Uri.parse(url));
    final response = await request.close();

    if (response.statusCode != 200) {
      print('خطا در دریافت فایل. کد وضعیت: ${response.statusCode}');
      return;
    }

    final stringData = await response.transform(utf8.decoder).join();
    final Map<String, dynamic> sourceData = json.decode(stringData);

    final Map<String, Map<String, int>> nodes = {};
    final Map<String, String> stationsFa = {};
    final Map<String, List<int>> stationsLines = {};
    
    // ۱. استخراج مختصات برای محاسبه فاصله
    final Map<String, _Coord> coords = {};
    sourceData.forEach((key, value) {
      final info = value as Map<String, dynamic>;
      final lat = double.tryParse(info['latitude']?.toString() ?? '') ?? 0.0;
      final lon = double.tryParse(info['longitude']?.toString() ?? '') ?? 0.0;
      coords[key] = _Coord(lat, lon);
    });

    sourceData.forEach((stationKey, value) {
      final stationInfo = value as Map<String, dynamic>;

      // ۲. استخراج نام فارسی
      final translations = stationInfo['translations'] as Map<String, dynamic>?;
      if (translations != null && translations['fa'] != null) {
        stationsFa[stationKey] = translations['fa'].toString();
      } else {
        stationsFa[stationKey] = stationKey;
      }

      // ۳. استخراج خطوط مترو
      final linesRaw = stationInfo['lines'] as List<dynamic>? ?? [];
      stationsLines[stationKey] = linesRaw.map((e) => e as int).toList();

      // ۴. استخراج اتصالات و محاسبه زمان بر اساس فاصله
      final relations = stationInfo['relations'] as List<dynamic>? ?? [];
      final Map<String, int> connections = {};
      
      final startCoord = coords[stationKey]!;
      
      for (var relation in relations) {
        final targetKey = relation.toString();
        final endCoord = coords[targetKey];
        
        int duration = 2; // مقدار پیش‌فرض ۲ دقیقه
        
        if (endCoord != null && startCoord.isValid && endCoord.isValid) {
          final distanceKm = _calculateDistance(
            startCoord.lat, startCoord.lon, 
            endCoord.lat, endCoord.lon
          );
          
          // میانگین سرعت مترو با احتساب توقف‌ها: ۴۰ کیلومتر بر ساعت
          // زمان (دقیقه) = (مسافت / سرعت) * ۶۰
          // زمان = مسافت * ۱.۵
          // اضافه کردن ۰.۵ دقیقه برای زمان توقف در ایستگاه
          duration = (distanceKm * 1.5 + 0.5).round();
          if (duration < 1) duration = 1; // حداقل ۱ دقیقه
        }
        
        connections[targetKey] = duration;
      }

      nodes[stationKey] = connections;
    });

    final outputData = {
      "lastUpdated": DateTime.now().toUtc().toIso8601String(),
      "nodes": nodes,
      "stationsFa": stationsFa,
      "stationsLines": stationsLines,
    };

    final encoder = const JsonEncoder.withIndent('  ');
    final formattedJson = encoder.convert(outputData);

    final file = File('metro_graph.json');

    await file.writeAsString(formattedJson, flush: true, encoding: utf8);

    print('استخراج و تبدیل با موفقیت انجام شد!');
    print('تعداد کل ایستگاه‌ها: ${stationsFa.length}');
  } catch (e) {
    print('خطایی رخ داد: $e');
  }
}

class _Coord {
  final double lat;
  final double lon;
  _Coord(this.lat, this.lon);
  bool get isValid => lat != 0.0 && lon != 0.0;
}

double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  const p = 0.017453292519943295; // Math.PI / 180
  final a = 0.5 - cos((lat2 - lat1) * p) / 2 +
      cos(lat1 * p) * cos(lat2 * p) *
      (1 - cos((lon2 - lon1) * p)) / 2;
  return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
}
