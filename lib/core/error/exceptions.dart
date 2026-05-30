// مسیر: lib/core/error/exceptions.dart

/// استثنای مربوط به خطاهای ارتباط با سرور و API
///
/// این خطا زمانی توسط [RemoteDataSource] پرتاب می‌شود که کدهای خطای HTTP
/// (مانند 404، 500) دریافت شود یا ارتباط در سطح پایین (Dio) با مشکل مواجه گردد.
class ServerException implements Exception {}

/// استثنای مربوط به خطاهای پایگاه داده و حافظه محلی
///
/// این خطا زمانی توسط [LocalDataSource] پرتاب می‌شود که نقشه مترو در
/// دیتابیس ObjectBox یافت نشود (مثلاً در اولین اجرای برنامه) یا خطایی در خواندن/نوشتن رخ دهد.
class CacheException implements Exception {}
