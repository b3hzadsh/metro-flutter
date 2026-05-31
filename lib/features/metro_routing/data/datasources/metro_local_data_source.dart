// مسیر: lib/features/metro_routing/data/datasources/metro_local_data_source.dart

import '../../../../core/error/exceptions.dart';
import '../models/metro_graph_model.dart';

import '../../../../objectbox.g.dart';

abstract class MetroLocalDataSource {
  Future<MetroGraphModel> getLastMetroGraph();

  Future<void> cacheMetroGraph(MetroGraphModel graphToCache);
}

class MetroLocalDataSourceImpl implements MetroLocalDataSource {
  final Store store;
  late final Box<MetroGraphModel> graphBox;

  MetroLocalDataSourceImpl({required this.store}) {
    graphBox = store.box<MetroGraphModel>();
  }

  @override
  Future<MetroGraphModel> getLastMetroGraph() async {
    try {
      print('🔵 DEBUG [LocalDataSource]: در حال خواندن نقشه از ObjectBox...');

      final graphs = graphBox.getAll();

      if (graphs.isNotEmpty) {
        print('🟢 DEBUG [LocalDataSource]: نقشه با موفقیت از کش خوانده شد.');
        return graphs.first;
      } else {
        print(
          '🟡 DEBUG [LocalDataSource]: هیچ نقشه‌ای در دیتابیس یافت نشد (دیتابیس خالی است).',
        );
        throw CacheException();
      }
    } catch (e) {
      print('🔴 FATAL [LocalDataSource]: خطا در خواندن دیتا از ObjectBox: $e');
      throw CacheException();
    }
  }

  @override
  Future<void> cacheMetroGraph(MetroGraphModel graphToCache) async {
    try {
      print('🔵 DEBUG [LocalDataSource]: در حال پاکسازی نقشه‌های قدیمی...');
      graphBox.removeAll();

      graphToCache.id = 0;

      print(
        '🔵 DEBUG [LocalDataSource]: در حال ذخیره نقشه جدید در ObjectBox...',
      );
      graphBox.put(graphToCache);

      print(
        '🟢 DEBUG [LocalDataSource]: نقشه با موفقیت در دیتابیس لوکال کش شد.',
      );
    } catch (e) {
      print('🔴 FATAL [LocalDataSource]: خطا در ذخیره دیتا در ObjectBox: $e');
      throw CacheException();
    }
  }
}
