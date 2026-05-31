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
    final graphResult = await repository.getMetroGraph();

    return graphResult.fold((failure) => Left(failure), (graph) {
      String? startKey;
      String? endKey;
      graph.stationsFa.forEach((key, value) {
        if (value == startStation || key == startStation) startKey = key;
        if (value == endStation || key == endStation) endKey = key;
      });

      if (startKey == null || endKey == null) {
        return const Left(
          RoutingFailure(
            'ایستگاه مبدا یا مقصد در نقشه یافت نشد. املای آن را بررسی کنید.',
          ),
        );
      }

      final nodes = graph.nodes;
      final distances = <String, int>{};
      final previous = <String, String>{};
      final unvisited = nodes.keys.toList();

      for (var node in nodes.keys) {
        distances[node] = 999999;
      }
      distances[startKey!] = 0;

      while (unvisited.isNotEmpty) {
        unvisited.sort((a, b) => distances[a]!.compareTo(distances[b]!));
        final currentNode = unvisited.first;
        unvisited.remove(currentNode);

        if (currentNode == endKey) break;

        final neighbors = nodes[currentNode] ?? {};
        for (var neighbor in neighbors.keys) {
          if (unvisited.contains(neighbor)) {
            final alt = distances[currentNode]! + neighbors[neighbor]!;
            if (alt < distances[neighbor]!) {
              distances[neighbor] = alt;
              previous[neighbor] = currentNode;
            }
          }
        }
      }

      if (distances[endKey] == 999999) {
        return const Left(RoutingFailure('مسیری بین این دو ایستگاه یافت نشد.'));
      }

      final path = <String>[];
      String? current = endKey;
      while (current != null) {
        path.insert(0, current);
        current = previous[current];
      }

      final stationsLines = graph.stationsLines;
      final stationsFa = graph.stationsFa;
      List<RouteLeg> legs = [];

      if (path.length > 1) {
        String startStationFa = stationsFa[path[0]] ?? path[0];
        List<String> currentLegStations = [startStationFa];

        List<int> startLines = stationsLines[path[0]] ?? [];
        List<int> nextLines = stationsLines[path[1]] ?? [];

        int currentLine = startLines.firstWhere(
          (l) => nextLines.contains(l),
          orElse: () => startLines.isNotEmpty ? startLines.first : 0,
        );

        for (int i = 1; i < path.length; i++) {
          String prevNode = path[i - 1];
          String currNode = path[i];
          String prevFa = stationsFa[prevNode] ?? prevNode;
          String currFa = stationsFa[currNode] ?? currNode;
          List<int> currLines = stationsLines[currNode] ?? [];

          if (currLines.contains(currentLine)) {
            currentLegStations.add(currFa);
          } else {
            legs.add(
              RouteLeg(
                line: currentLine,
                stationsFa: List.from(currentLegStations),
              ),
            );

            List<int> prevLines = stationsLines[prevNode] ?? [];
            int newLine = prevLines.firstWhere(
              (l) => currLines.contains(l),
              orElse: () => currLines.isNotEmpty ? currLines.first : 0,
            );

            currentLine = newLine;
            currentLegStations = [prevFa, currFa];
          }
        }
        if (currentLegStations.isNotEmpty) {
          legs.add(RouteLeg(line: currentLine, stationsFa: currentLegStations));
        }
      } else {
        legs.add(
          RouteLeg(
            line: (stationsLines[path[0]]?.isNotEmpty ?? false)
                ? stationsLines[path[0]]!.first
                : 0,
            stationsFa: [stationsFa[path[0]] ?? path[0]],
          ),
        );
      }

      return Right(
        MetroRoute(legs: legs, estimatedTimeMinutes: distances[endKey]!),
      );
    });
  }
}
