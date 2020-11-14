import 'dart:convert';
import 'dart:io';

Future<File> _localFile(String filename) async {
  return File('${Directory.current.path}/res/output/${filename}.json');
}

void readFromFile(String path) async {
  final dataFromFile = (await _localFile(path)).readAsStringSync();
  final decodedData = jsonDecode(dataFromFile) as List;
  final trains = [];
  final date = DateTime.now();
  for (final route in decodedData) {
    if (checkTrainHasRoute(route, '41092', '32015')) {
      if (checkTrainTime(route, date)) {
        trains.add(route['id']);
      }
    }
  }
  print(trains);
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

bool checkTrainHasRoute(
  Map<String, dynamic> train,
  String originCode,
  String destCode,
) {
  final traseu = train['traseu']['traseu'] as List;
  bool findOrigin = false;
  for (final oprire in traseu) {
    if (oprire['statieInitiala'] == originCode) {
      findOrigin = true;
    }
    if (oprire['statieFinala'] == destCode && findOrigin) {
      return true;
    }
  }
  return false;
}
