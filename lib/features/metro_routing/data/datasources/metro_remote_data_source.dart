// مسیر: lib/features/metro_routing/data/datasources/metro_remote_data_source.dart

import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../models/metro_graph_model.dart';

abstract class MetroRemoteDataSource {
  Future<MetroGraphModel> downloadGraph();
}

class MetroRemoteDataSourceImpl implements MetroRemoteDataSource {
  final Dio dio;

  static const String url =
      'https://gist.githubusercontent.com/b3hzadsh/9cc5e93cee99da4cb044f567c778c540/raw/18a81f1ab8043ec30e783732708a50d72d287383/metro_graph.json';

  MetroRemoteDataSourceImpl({required this.dio});

  @override
  Future<MetroGraphModel> downloadGraph() async {
    try {
      print('🔵 DEBUG [DataSource]: شروع درخواست به سرور...');

      final response = await dio.get(url);

      if (response.statusCode == 200) {
        print('🟢 DEBUG [DataSource]: پاسخ سرور دریافت شد. وضعیت: 200');

        Map<String, dynamic> jsonMap;

        if (response.data is String) {
          print(
            '🔵 DEBUG [DataSource]: تشخیص فرمت متنی خام (String). در حال رمزگشایی با استاندارد UTF-8...',
          );
          jsonMap =
              json.decode(response.data as String) as Map<String, dynamic>;
        } else if (response.data is Map) {
          print('🔵 DEBUG [DataSource]: تشخیص فرمت ساختاریافته (Map).');
          jsonMap = response.data as Map<String, dynamic>;
        } else {
          throw ServerException();
        }

        print(
          '🔵 DEBUG [DataSource]: در حال پارس کردن JSON به مدل ObjectBox...',
        );
        final model = MetroGraphModel.fromJson(jsonMap);

        print('🟢 DEBUG [DataSource]: تبدیل به مدل با موفقیت انجام شد.');
        return model;
      } else {
        print(
          '🔴 FATAL [DataSource]: سرور پاسخ نامعتبر داد. کد وضعیت: ${response.statusCode}',
        );
        throw ServerException();
      }
    } on DioException catch (e) {
      print('🔴 FATAL [Dio Network Error]: خطای ارتباطی Dio.');
      print('نوع خطا: ${e.type}');
      print('پیام خطا: ${e.message}');
      if (e.response != null) {
        print('دیتای خطای دریافتی از سرور: ${e.response?.data}');
      }
      throw ServerException();
    } catch (e, stackTrace) {
      print('🔴 FATAL [JSON Parse Error]: خطا در تبدیل داده به مدل.');
      print('دلیل خطا: $e');
      print('Stack: $stackTrace');
      throw ServerException();
    }
  }
}
