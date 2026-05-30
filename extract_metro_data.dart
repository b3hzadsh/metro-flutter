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

    // خواندن دیتای سرور و دیکد کردن صریح به صورت UTF-8
    final stringData = await response.transform(utf8.decoder).join();
    final Map<String, dynamic> sourceData = json.decode(stringData);

    final Map<String, Map<String, int>> nodes = {};
    final Map<String, String> stationsFa = {};

    sourceData.forEach((stationKey, value) {
      final stationInfo = value as Map<String, dynamic>;

      // استخراج نام فارسی
      final translations = stationInfo['translations'] as Map<String, dynamic>?;
      if (translations != null && translations['fa'] != null) {
        stationsFa[stationKey] = translations['fa'].toString();
      } else {
        stationsFa[stationKey] = stationKey;
      }

      // استخراج لیست همسایه‌ها
      final relations = stationInfo['relations'] as List<dynamic>? ?? [];
      final Map<String, int> connections = {};
      for (var relation in relations) {
        connections[relation.toString()] = 2; // زمان پیش‌فرض ۲ دقیقه
      }

      nodes[stationKey] = connections;
    });

    final outputData = {
      "lastUpdated": DateTime.now().toUtc().toIso8601String(),
      "nodes": nodes,
      "stationsFa": stationsFa,
    };

    final encoder = const JsonEncoder.withIndent('  ');
    final formattedJson = encoder.convert(outputData);

    final file = File('metro_graph.json');

    // ==========================================================
    // بخش اصلاح شده: اجبار به استفاده از UTF-8 هنگام ذخیره فایل
    // ==========================================================
    await file.writeAsString(
      formattedJson,
      flush: true,
      encoding: utf8, // این پارامتر مشکل حروف فارسی را حل می‌کند
    );

    print('استخراج و تبدیل با موفقیت انجام شد!');
    print(
      'نمونه تست فارسی ذخیره شده: ${stationsFa.keys.first} -> ${stationsFa.values.first}',
    );
    print('فایل نهایی در مسیر ${file.absolute.path} قرار گرفت.');
  } catch (e) {
    print('خطایی در حین پردازش رخ داد: $e');
  }
}
