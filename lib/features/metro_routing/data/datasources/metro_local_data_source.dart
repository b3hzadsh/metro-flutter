// مسیر: lib/features/metro_routing/data/datasources/metro_local_data_source.dart

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/metro_graph.dart';
import '../models/metro_graph_model.dart';
import '../../../../objectbox.g.dart'; // فایلی که در مرحله قبل تولید شد

abstract class MetroLocalDataSource {
  Future<MetroGraphModel> getMetroGraph();
  Future<void> cacheMetroGraph(MetroGraph graphToCache);
}

class MetroLocalDataSourceImpl implements MetroLocalDataSource {
  // صندوقچه مخصوص گراف مترو در ObjectBox
  final Box<MetroGraphModel> graphBox;

  MetroLocalDataSourceImpl({required this.graphBox});

  @override
  Future<MetroGraphModel> getMetroGraph() async {
    // از آنجایی که ما فقط یک گراف داریم، همیشه اولین رکورد را می‌خوانیم
    final graph = graphBox.get(1); 
    
    if (graph != null) {
      return graph;
    } else {
      throw CacheException();
    }
  }

  @override
  Future<void> cacheMetroGraph(MetroGraph graphToCache) async {
    // تبدیل Entity به Model
    final modelToCache = MetroGraphModel.fromEntity(graphToCache);
    
    // تنظیم آیدی روی ۱ تا همیشه رکورد قبلی را آپدیت (Overwrite) کند
    modelToCache.id = 1; 
    
    graphBox.put(modelToCache);
  }
}