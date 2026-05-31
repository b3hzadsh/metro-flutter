import 'dart:convert';
import 'dart:io';

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
    final Map<String, List<int>> stationsLines =
        {}; // 👈 مپ جدید برای خطوط مترو

    sourceData.forEach((stationKey, value) {
      final stationInfo = value as Map<String, dynamic>;

      // ۱. استخراج نام فارسی
      final translations = stationInfo['translations'] as Map<String, dynamic>?;
      if (translations != null && translations['fa'] != null) {
        stationsFa[stationKey] = translations['fa'].toString();
      } else {
        stationsFa[stationKey] = stationKey;
      }

      // ۲. استخراج خطوط مترو (دقت در تبدیل تایپ به int)
      final linesRaw = stationInfo['lines'] as List<dynamic>? ?? [];
      stationsLines[stationKey] = linesRaw.map((e) => e as int).toList();

      // ۳. استخراج اتصالات و همسایه‌ها
      final relations = stationInfo['relations'] as List<dynamic>? ?? [];
      final Map<String, int> connections = {};
      for (var relation in relations) {
        connections[relation.toString()] = 2; // زمان تقریبی ۲ دقیقه
      }

      nodes[stationKey] = connections;
    });

    final outputData = {
      "lastUpdated": DateTime.now().toUtc().toIso8601String(),
      "nodes": nodes,
      "stationsFa": stationsFa,
      "stationsLines": stationsLines, // 👈 اضافه شدن به خروجی نهایی
    };

    final encoder = const JsonEncoder.withIndent('  ');
    final formattedJson = encoder.convert(outputData);

    final file = File('metro_graph.json');

    await file.writeAsString(formattedJson, flush: true, encoding: utf8);

    print('استخراج و تبدیل با موفقیت انجام شد!');
    print('تست خطوط تجریش: ${stationsLines['Tajrish']}'); // خروجی باید [1] باشد
  } catch (e) {
    print('خطایی رخ داد: $e');
  }
}
