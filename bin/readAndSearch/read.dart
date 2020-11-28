import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:equatable/equatable.dart';

Future<File> _localFile(String filename) async {
  return File('${Directory.current.path}/res/output/graph/${filename}.json');
}

void readFromFile(String path) async {
  final dataFromFile = (await _localFile(path)).readAsStringSync();
  final decodedData = jsonDecode(dataFromFile);
  final List<List<StationTrain>> allPaths = bfs(decodedData, '41092', '41195');
  allPaths.forEach((element) {
    print('${element.first} - ${element.last}');
  });
}

List<List<StationTrain>> bfs(
    Map<String, dynamic> trains, String originNode, String destNode) {
  if (trains.containsKey(originNode)) {
    final Queue<List<StationTrain>> queue = Queue();
    final Set<StationTrain> visited = {};
    final List<List<StationTrain>> allPaths = [];
    for (final node in trains[originNode]) {
      final StationTrain firstNode = StationTrain(originNode, node['trainId']);
      visited.add(firstNode);
      queue.addFirst([firstNode]);
    }
    while (queue.isNotEmpty) {
      final List quePaths = queue.removeFirst();
      StationTrain last = quePaths.last;
      if (last.stationId == destNode) {
        final List<StationTrain> newListToCoppy = [...quePaths];
        allPaths.add(newListToCoppy);
      }
      if (trains.containsKey(last.stationId)) {
        final trainsFromStation = trains[last.stationId] as List;
        for (final train in trainsFromStation) {
          final StationTrain newStationTrain =
              StationTrain(train['statieFinala'], train['trainId']);
          if (!visited.contains(newStationTrain) &&
              train['trainId'] == last.trainId) {
            final List<StationTrain> newPath = [...quePaths];
            newPath.add(newStationTrain);
            visited.add(newStationTrain);
            queue.addFirst(newPath);
          }
        }
      }
    }
    return allPaths;
  }
  return [];
}

bool checkTrainTime(Map<String, dynamic> train, DateTime date) {
  final restrictii = train['restrictii'] as List;
  for (final restrictie in restrictii) {
    final deLa = DateTime.parse(restrictie['deLa']);
    final panala = DateTime.parse(restrictie['panala']);
    if (date.isAfter(deLa) && date.isBefore(panala)) {
      return true;
    }
  }
  return false;
}

class StationTrain extends Equatable {
  final String stationId;
  final String trainId;

  StationTrain(this.stationId, this.trainId);

  @override
  List<Object> get props => [stationId, trainId];

  @override
  bool get stringify => true;
}
