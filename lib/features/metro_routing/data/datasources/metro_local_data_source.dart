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
      // DEBUG log removed

      final graphs = graphBox.getAll();

      if (graphs.isNotEmpty) {
        // DEBUG log removed
        return graphs.first;
      } else {
        // DEBUG log removed
        throw CacheException();
      }
    } catch (e) {
      // FATAL log removed
      throw CacheException();
    }
  }

  @override
  Future<void> cacheMetroGraph(MetroGraphModel graphToCache) async {
    try {
      // DEBUG log removed
      graphBox.removeAll();

      graphToCache.id = 0;

      // DEBUG log removed
      graphBox.put(graphToCache);

      // DEBUG log removed
    } catch (e) {
      // FATAL log removed
      throw CacheException();
    }
  }
}
