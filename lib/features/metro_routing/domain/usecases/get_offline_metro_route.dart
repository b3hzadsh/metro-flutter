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
          RoutingFailure('ایستگاه مبدا یا مقصد در نقشه یافت نشد.'),
        );
      }

      final nodes = graph.nodes;
      final stationsLines = graph.stationsLines;
      final stationsFa = graph.stationsFa;
      final distances = <String, int>{};
      final previous = <String, String>{};
      final arrivedOnLine = <String, int>{};
      final unvisited = nodes.keys.toList();

      const int TRANSFER_PENALTY = 8;

      for (var node in nodes.keys) {
        distances[node] = 999999;
      }
      distances[startKey!] = 0;

      while (unvisited.isNotEmpty) {
        unvisited.sort((a, b) => distances[a]!.compareTo(distances[b]!));
        final currentNode = unvisited.first;
        unvisited.remove(currentNode);

        if (currentNode == endKey) break;
        if (distances[currentNode] == 999999) break;

        final neighbors = nodes[currentNode] ?? {};
        for (var neighbor in neighbors.keys) {
          if (unvisited.contains(neighbor)) {
            final currentLines = stationsLines[currentNode] ?? [];
            final neighborLines = stationsLines[neighbor] ?? [];
            final connectingLines = currentLines
                .where((l) => neighborLines.contains(l))
                .toList();

            int edgeCost = neighbors[neighbor]!;
            int selectedLineForMove = 0;

            if (currentNode == startKey) {
              selectedLineForMove = connectingLines.isNotEmpty
                  ? connectingLines.first
                  : (currentLines.isNotEmpty ? currentLines.first : 0);
            } else {
              final arrivalLine = arrivedOnLine[currentNode] ?? 0;
              if (connectingLines.contains(arrivalLine)) {
                selectedLineForMove = arrivalLine;
              } else {
                edgeCost += TRANSFER_PENALTY;
                selectedLineForMove = connectingLines.isNotEmpty
                    ? connectingLines.first
                    : arrivalLine;
              }
            }
            final alt = distances[currentNode]! + edgeCost;
            if (alt < distances[neighbor]!) {
              distances[neighbor] = alt;
              previous[neighbor] = currentNode;
              arrivedOnLine[neighbor] = selectedLineForMove;
            }
          }
        }
      }

      if (distances[endKey] == 999999) {
        return const Left(RoutingFailure('مسیری بین این دو ایستگاه یافت نشد.'));
      }

      final rawPath = <String>[];
      String? current = endKey;
      while (current != null) {
        rawPath.insert(0, current);
        current = previous[current];
      }
      List<RouteLeg> legs = [];

      if (rawPath.length > 1) {
        String startStationFa = stationsFa[rawPath[0]] ?? rawPath[0];
        List<String> currentLegStations = [startStationFa];

        List<int> startLines = stationsLines[rawPath[0]] ?? [];
        List<int> nextLines = stationsLines[rawPath[1]] ?? [];

        int currentLine = startLines.firstWhere(
          (l) => nextLines.contains(l),
          orElse: () => startLines.isNotEmpty ? startLines.first : 0,
        );

        for (int i = 1; i < rawPath.length; i++) {
          String prevNode = rawPath[i - 1];
          String currNode = rawPath[i];

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
            line: (stationsLines[rawPath[0]]?.isNotEmpty ?? false)
                ? stationsLines[rawPath[0]]!.first
                : 0,
            stationsFa: [stationsFa[rawPath[0]] ?? rawPath[0]],
          ),
        );
      }

      return Right(
        MetroRoute(legs: legs, estimatedTimeMinutes: distances[endKey]!),
      );
    });
  }
}
