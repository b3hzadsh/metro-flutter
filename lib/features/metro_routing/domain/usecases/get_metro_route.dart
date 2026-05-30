// مسیر: lib/features/metro_routing/domain/usecases/get_metro_route.dart

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/metro_route.dart';
import '../repositories/metro_repository.dart';

class GetMetroRoute {
  final MetroRepository repository;

  GetMetroRoute(this.repository);

  Future<Either<Failure, MetroRoute>> call({
    required String startStation,
    required String endStation,
  }) async {
    try {
      final graphEither = await repository.getMetroGraph();

      return graphEither.fold((failure) => Left(failure), (graph) {
        final nodes = graph.nodes;
        final stationsFa = graph.stationsFa;

        // تابع کمکی (Reverse Lookup) برای تبدیل ورودی فارسی به کلید انگلیسی
        String resolveStationKey(String input) {
          // اگر کاربر کلید انگلیسی را دقیق وارد کرده بود
          if (nodes.containsKey(input)) return input;

          // اگر فارسی تایپ کرده بود، کلید انگلیسی معادل را پیدا کن
          for (var entry in stationsFa.entries) {
            if (entry.value == input) return entry.key;
          }
          return input; // اگر پیدا نشد، همان ورودی را برگردان
        }

        final resolvedStart = resolveStationKey(startStation);
        final resolvedEnd = resolveStationKey(endStation);

        if (!nodes.containsKey(resolvedStart) ||
            !nodes.containsKey(resolvedEnd)) {
          return const Left(
            RoutingFailure(
              'ایستگاه مبدا یا مقصد در نقشه یافت نشد. املای آن را بررسی کنید.',
            ),
          );
        }

        // --- شروع دایجسترا با کلیدهای انگلیسی ---
        final distances = <String, int>{};
        final previousNodes = <String, String>{};
        final unvisited = nodes.keys.toList();

        for (var node in nodes.keys) {
          distances[node] = 999999;
        }
        distances[resolvedStart] = 0;

        while (unvisited.isNotEmpty) {
          unvisited.sort((a, b) => distances[a]!.compareTo(distances[b]!));
          final currentNode = unvisited.first;

          if (distances[currentNode] == 999999) break;
          if (currentNode == resolvedEnd) break;

          unvisited.remove(currentNode);

          final neighbors = nodes[currentNode] ?? {};
          for (var neighbor in neighbors.entries) {
            final altDistance = distances[currentNode]! + neighbor.value;
            if (altDistance < (distances[neighbor.key] ?? 999999)) {
              distances[neighbor.key] = altDistance;
              previousNodes[neighbor.key] = currentNode;
            }
          }
        }

        // --- بازسازی مسیر و ترجمه به فارسی ---
        if (!previousNodes.containsKey(resolvedEnd) &&
            resolvedStart != resolvedEnd) {
          return const Left(
            RoutingFailure('مسیری بین این دو ایستگاه یافت نشد.'),
          );
        }

        final pathFa = <String>[];
        String? current = resolvedEnd;

        while (current != null) {
          // دریافت نام فارسی ایستگاه برای نمایش در UI
          final faName = stationsFa[current] ?? current;
          pathFa.insert(0, faName);
          current = previousNodes[current];
        }

        return Right(
          MetroRoute(
            path: pathFa, // لیست نهایی حاوی اسامی فارسی است
            estimatedTimeMinutes: distances[resolvedEnd] ?? 0,
          ),
        );
      });
    } catch (e) {
      return const Left(RoutingFailure('خطای غیرمنتظره در محاسبه مسیر.'));
    }
  }
}
