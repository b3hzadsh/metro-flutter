// مسیر: lib/features/metro_routing/domain/usecases/get_offline_metro_route.dart

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/metro_route.dart';
import '../repositories/metro_repository.dart';

class GetOfflineMetroRoute {
  final MetroRepository repository;

  GetOfflineMetroRoute(this.repository);

  Future<Either<Failure, MetroRoute>> call({
    required String startStation,
    required String endStation,
  }) async {
    try {
      // ۱. دریافت کل گراف شبکه از دیتابیس لوکال
      final graphEither = await repository.getMetroGraph();

      return graphEither.fold((failure) => Left(failure), (graph) {
        final nodes = graph.nodes;

        // اعتبارسنجی اولیه
        if (!nodes.containsKey(startStation) ||
            !nodes.containsKey(endStation)) {
          return const Left(
            RoutingFailure('ایستگاه مبدا یا مقصد در نقشه یافت نشد.'),
          );
        }

        // ==========================================
        // شروع پیاده‌سازی الگوریتم دایجسترا (Dijkstra)
        // ==========================================

        final distances = <String, int>{};
        final previousNodes = <String, String>{};
        final unvisited = nodes.keys.toList();

        // الف) مقداردهی اولیه: فاصله تا همه بی‌نهایت، فاصله تا مبدا صفر
        for (var node in nodes.keys) {
          distances[node] = 999999; // استفاده از عدد بزرگ به جای بی‌نهایت
        }
        distances[startStation] = 0;

        // ب) حلقه اصلی: تا زمانی که گره ملاقات‌نشده‌ای داریم
        while (unvisited.isNotEmpty) {
          // پیدا کردن گرهی که کمترین فاصله را در لیست ملاقات‌نشده‌ها دارد
          unvisited.sort((a, b) => distances[a]!.compareTo(distances[b]!));
          final currentNode = unvisited.first;

          // اگر کمترین فاصله بی‌نهایت است، یعنی بقیه گراف در دسترس نیست
          if (distances[currentNode] == 999999) break;

          // اگر به مقصد رسیدیم، جستجو را متوقف کن (بهینه‌سازی خروج زودهنگام)
          if (currentNode == endStation) break;

          unvisited.remove(currentNode);

          // ج) بررسی همسایه‌ها (ایستگاه‌های متصل)
          final neighbors = nodes[currentNode] ?? {};
          for (var neighbor in neighbors.entries) {
            final neighborName = neighbor.key;
            final timeToNeighbor = neighbor.value;

            // محاسبه زمان کل از مبدا تا این همسایه
            final altDistance = distances[currentNode]! + timeToNeighbor;

            // اگر مسیر جدید سریع‌تر از مسیر قبلی است، آن را جایگزین کن
            if (altDistance < (distances[neighborName] ?? 999999)) {
              distances[neighborName] = altDistance;
              // ثبت ردپا (Breadcrumb) برای اینکه بدانیم از کجا به این ایستگاه رسیدیم
              previousNodes[neighborName] = currentNode;
            }
          }
        }

        // ==========================================
        // بازسازی مسیر (Path Reconstruction)
        // ==========================================

        // اگر ردپایی به مقصد وجود ندارد، یعنی مسیری نیست
        if (!previousNodes.containsKey(endStation) &&
            startStation != endStation) {
          return const Left(
            RoutingFailure('مسیری بین این دو ایستگاه یافت نشد.'),
          );
        }

        final path = <String>[];
        String? current = endStation;

        // حرکت از مقصد به سمت مبدا با استفاده از ردپاها
        while (current != null) {
          path.insert(0, current); // اضافه کردن به ابتدای لیست
          current = previousNodes[current];
        }

        final totalEstimatedTime = distances[endStation] ?? 0;

        // بازگرداندن موجودیت مسیر (همان فرمتی که UI انتظار دارد)
        return Right(
          MetroRoute(path: path, estimatedTimeMinutes: totalEstimatedTime),
        );
      });
    } catch (e) {
      return const Left(RoutingFailure('خطای غیرمنتظره در محاسبه مسیر.'));
    }
  }
}
