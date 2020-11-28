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
  final String source = '41092';
  final String destination = '32015';
  for (final route in decodedData) {
    if (checkTrainHasRoute(route, source, destination)) {
      if (checkTrainTime(route, date)) {
        final Train trainParsed = parseTrainFromMap(
          route,
          company,
          source,
          DateTime.now(),
        );
        if (trainParsed != null) {
          trains.add(trainParsed);
        } else {
          print('ok');
        }
      }
    }
  }
  print(trains);
}

Train parseTrainFromMap(
  Map<String, dynamic> mapTrain,
  String company,
  String source,
  DateTime date,
) {
  final id = mapTrain['id'];
  final category = mapTrain['categorie'];
  final Map<String, dynamic> parseResult = parseStops(
    mapTrain['traseu']['traseu'] as List<dynamic>,
    source,
  );
  final bool shouldSubstractOne = parseResult['shouldSubstractOne'];
  final DateTime timeToCheck =
      shouldSubstractOne ? date.subtract(Duration(days: 1)) : date;
  final List<Stop> stops = parseResult['stops'];
  return checkTrainTime(mapTrain, timeToCheck)
      ? Train(id, stops, company, category)
      : null;
}

int calculateSeconsdFromString(String hourMinutes) {
  final hour = int.parse(hourMinutes.split(':')[0]);
  final minute = int.parse(hourMinutes.split(':')[1]);
  return hour * 3600 + minute * 60;
}

Map<String, dynamic> parseStops(List<dynamic> mapTraseu, String source) {
  final List<Stop> stops = [];
  bool shouldSubstractOne = false;
  bool isOverNight = false;
  bool foundSource = false;
  for (int i = 0; i < mapTraseu.length; ++i) {
    if (mapTraseu[i]['stationId'] == source) {
      foundSource = true;
    }
    final timeStart =
        parseTime(mapTraseu[i]['oraPornire'] as Map<String, dynamic>);
    final timeArriveNext =
        parseTime(mapTraseu[i]['oraSosire'] as Map<String, dynamic>);
    final firstTime = calculateSeconsdFromString(timeStart);
    final secondTime = calculateSeconsdFromString(timeArriveNext);
    final stationId = mapTraseu[i]['statieInitiala'] as String;
    if (secondTime < firstTime) {
      print('*' * 20);
      print(stationId);
      print(timeStart);
      print(timeArriveNext);
      print('*' * 20);
      isOverNight = true;
    }
    if (isOverNight && foundSource) {
      shouldSubstractOne = true;
    }
    final distanta = mapTraseu[i]['distanta'] as double;
    final vitezaLivret = mapTraseu[i]['vitezaLivret'] as int;
    final Stop stop =
        Stop(stationId, timeStart, timeArriveNext, vitezaLivret, distanta);
    stops.add(stop);
  }
  if (isOverNight) {
    print('ok');
  }
  return {'shouldSubstractOne': shouldSubstractOne, 'stops': stops};
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
