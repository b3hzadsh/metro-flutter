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
      // DEBUG log removed

      final response = await dio.get(url);

      if (response.statusCode == 200) {
        // DEBUG log removed

        Map<String, dynamic> jsonMap;

        if (response.data is String) {
          // DEBUG log removed
          jsonMap =
              json.decode(response.data as String) as Map<String, dynamic>;
        } else if (response.data is Map) {
          // DEBUG log removed
          jsonMap = response.data as Map<String, dynamic>;
        } else {
          throw ServerException();
        }

        // DEBUG log removed
        final model = MetroGraphModel.fromJson(jsonMap);

        // DEBUG log removed
        return model;
      } else {
        // FATAL log removed
        throw ServerException();
      }
    } on DioException catch (_) {
      // Network Error log removed
      throw ServerException();
    } catch (_) {
      // JSON Parse Error log removed
      throw ServerException();
    }
  }
}
