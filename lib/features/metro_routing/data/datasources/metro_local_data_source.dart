// مسیر: lib/features/metro_routing/data/datasources/metro_local_data_source.dart

import '../../../../core/error/exceptions.dart';
import '../models/metro_graph_model.dart';

// ایمپورت فایل‌های جنریت‌شده ObjectBox (مسیر ممکن است بسته به ساختار پروژه شما کمی متفاوت باشد)
import '../../../../objectbox.g.dart'; 

abstract class MetroLocalDataSource {
  /// آخرین نقشه ذخیره شده در دیتابیس را برمی‌گرداند.
  /// اگر نقشه‌ای وجود نداشته باشد، [CacheException] پرتاب می‌کند.
  Future<MetroGraphModel> getLastMetroGraph();

  /// نقشه جدید دریافت شده از سرور را در دیتابیس محلی ذخیره می‌کند.
  Future<void> cacheMetroGraph(MetroGraphModel graphToCache);
}

class MetroLocalDataSourceImpl implements MetroLocalDataSource {
  final Store store;
  late final Box<MetroGraphModel> graphBox;

  MetroLocalDataSourceImpl({required this.store}) {
    // راه‌اندازی باکْس اختصاصی مدل مترو از روی Store اصلی
    graphBox = store.box<MetroGraphModel>();
  }

  @override
  Future<MetroGraphModel> getLastMetroGraph() async {
    try {
      print('🔵 DEBUG [LocalDataSource]: در حال خواندن نقشه از ObjectBox...');
      
      // دریافت تمام رکوردهای موجود (که منطقاً همیشه باید یک عدد باشد)
      final graphs = graphBox.getAll();
      
      if (graphs.isNotEmpty) {
        print('🟢 DEBUG [LocalDataSource]: نقشه با موفقیت از کش خوانده شد.');
        // همیشه اولین گراف موجود را برمی‌گردانیم
        return graphs.first;
      } else {
        print('🟡 DEBUG [LocalDataSource]: هیچ نقشه‌ای در دیتابیس یافت نشد (دیتابیس خالی است).');
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
      // ۱. پاک کردن دیتای قبلی برای جلوگیری از تداخل و مدیریت بهینه حافظه
      graphBox.removeAll();

      // ۲. صفر کردن ID برای اینکه ObjectBox بداند این یک رکورد کاملاً جدید است
      // و مشکل OBX_ERROR code 10002 برطرف شود.
      graphToCache.id = 0;

      print('🔵 DEBUG [LocalDataSource]: در حال ذخیره نقشه جدید در ObjectBox...');
      // ۳. اینزرت (Insert) گراف جدید در دیتابیس
      graphBox.put(graphToCache);
      
      print('🟢 DEBUG [LocalDataSource]: نقشه با موفقیت در دیتابیس لوکال کش شد.');
    } catch (e) {
      print('🔴 FATAL [LocalDataSource]: خطا در ذخیره دیتا در ObjectBox: $e');
      throw CacheException();
    }
  }
}