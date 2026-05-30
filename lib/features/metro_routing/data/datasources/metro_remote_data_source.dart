// مسیر: lib/features/metro_routing/data/datasources/metro_remote_data_source.dart

import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../models/metro_graph_model.dart';

// ۱. قرارداد (Interface): تعریف کلاسی که بقیه قرار است آن را پیاده‌سازی کنند
abstract class MetroRemoteDataSource {
  /// دریافت فایل کامل گراف شبکه مترو از سرور
  Future<MetroGraphModel> downloadGraph();
}

// ۲. پیاده‌سازی (Implementation): کلاسی که کد واقعی ارتباط با شبکه را دارد
class MetroRemoteDataSourceImpl implements MetroRemoteDataSource {
  final Dio dio;

  MetroRemoteDataSourceImpl({required this.dio});

  @override
  Future<MetroGraphModel> downloadGraph() async {
    // آدرس فرضی API شما که JSON گراف کل مترو را برمی‌گرداند
    const url =
        'https://gist.github.com/b3hzadsh/9cc5e93cee99da4cb044f567c778c540/raw/86c3e2a4da6ebfbb9bb56e9d201eecb1180c4cc6/metro_graph.json';

    try {
      final response = await dio.get(
        url,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200) {
        // داده‌ها (response.data) به صورت خودکار توسط Dio از JSON پارس می‌شوند
        return MetroGraphModel.fromJson(response.data);
      } else {
        throw ServerException();
      }
    } on DioException {
      // مدیریت خطاهای اختصاصی اینترنت و تایم‌اوت در Dio
      throw ServerException();
    } catch (e) {
      // مدیریت خطاهایی مثل مشکل در پارس کردن JSON
      throw ServerException();
    }
  }
}
