import 'dart:convert';
import 'dart:io';

import 'models/train.dart';

Future<File> _localFile(String filename) async {
  return File('${Directory.current.path}/res/output/${filename}.json');
}

String getCompanyFromFilename(String filename) {
  switch (filename) {
    case 'mers-tren-regio-calatori-2019-2020':
      return 'regio';
    case 'mers-tren-softrans-2019-2020':
      return 'soft';
    case 'mers-trenastra-trans-carpatic2019-2020':
      return 'astra';
    case 'mers-trencalea-ferata-din-moldova2019-2020':
      return 'cfm';
    case 'mers-treninterregional2019-2020':
      return 'interregio';
    case 'mers-trensntfc2019-2020':
      return 'cfr';
    case 'mers-trentransferoviar-calatori-2019-2020':
      return 'cfr';
    default:
      return null;
  }
}

void readOldFromFile(String path) async {
  final dataFromFile = (await _localFile(path)).readAsStringSync();
  final decodedData = jsonDecode(dataFromFile) as List;
  final List<Train> trains = [];
  final date = DateTime.now();
  final String company = getCompanyFromFilename(path);
  for (final route in decodedData) {
    if (checkTrainHasRoute(route, '41092', '32015')) {
      if (checkTrainTime(route, date)) {
        trains.add(parseTrainFromMap(route, company));
      }
    }
  }
  print(trains);
}

Train parseTrainFromMap(Map<String, dynamic> mapTrain, final company) {
  final id = mapTrain['id'];
  final category = mapTrain['categorie'];
  final List<Stop> stops = parseStops(
    mapTrain['traseu']['traseu'] as List<dynamic>,
  );
  return Train(id, stops, company, category);
}

List<Stop> parseStops(List<dynamic> mapTraseu) {
  final List<Stop> stops = [];
  for (int i = 0; i < mapTraseu.length; ++i) {
    if (i != 0) {
      //check date
    }
    final distanta = mapTraseu[i]['distanta'] as double;
    final stationId = mapTraseu[i]['statieInitiala'] as String;
    final timeStart =
        parseTime(mapTraseu[i]['oraPornire'] as Map<String, dynamic>);
    final timeArriveNext =
        parseTime(mapTraseu[i]['oraSosire'] as Map<String, dynamic>);
    final vitezaLivret = mapTraseu[i]['vitezaLivret'] as int;
    final Stop stop =
        Stop(stationId, timeStart, timeArriveNext, vitezaLivret, distanta);
    stops.add(stop);
  }
  return stops;
}

String parseTime(Map<String, dynamic> mapTime) {
  return '${mapTime["hours"]}:${mapTime["minutes"]}';
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
