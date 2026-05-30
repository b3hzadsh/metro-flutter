// مسیر: test/fixtures/fixture_reader.dart

import 'dart:io';

/// این تابع نام فایل را می‌گیرد و محتوای آن را به صورت یک رشته متنی برمی‌گرداند.
String fixture(String name) => File('test/fixtures/$name').readAsStringSync();
