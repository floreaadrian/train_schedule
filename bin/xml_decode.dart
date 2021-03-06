import 'dart:io';

import 'package:xml/xml.dart';

import 'writing.dart';

void decode(String path) async {
  final file = File('res/xml/${path}.xml');
  final document = XmlDocument.parse(file.readAsStringSync());
  final trains = document.findAllElements('Tren');
  final Map<String, dynamic> allStations = {};
  final Map<String, dynamic> allTrainDetails = {};
  for (final train in trains) {
    final result = _decodeAsUnderictedGraph(train);
    final trainDetails = _getTrainDetails(train);
    allTrainDetails.addAll(trainDetails);
    for (final station in result.keys) {
      if (allStations.containsKey(station)) {
        allStations[station].addAll(result[station]);
      } else {
        allStations[station] = result[station];
      }
    }
  }
  // print(allStations);
  await writeCounter(allStations, 'graph/$path');
  await writeCounter(allTrainDetails, 'trains/$path');
}

void oldDecode(String path) async {
  final file = File('res/xml/${path}.xml');
  final document = XmlDocument.parse(file.readAsStringSync());
  final trains = document.findAllElements('Tren');
  final List dataToWrite = [];
  for (final train in trains) {
    dataToWrite.add(decodeTren(train));
  }
  await writeCounter(dataToWrite, path);
}

Map<String, dynamic> _getTrainDetails(XmlElement tren) {
  final trainId = elementAttributeValue(tren, 'Numar');
  final categorie = elementAttributeValue(tren, 'CategorieTren');
  final restrictii =
      decodeRestrictii(tren.findAllElements('RestrictiiTren').first);
  return {
    trainId: {
      'categorie': categorie,
      'restrictii': restrictii,
    }
  };
}

Map<String, List<dynamic>> _decodeAsUnderictedGraph(XmlElement tren) {
  final traseu =
      tren.findAllElements('Trasa').first.findAllElements('ElementTrasa');
  final Map<String, List<dynamic>> nodes = {};
  traseu.forEach((element) {
    final trainId = elementAttributeValue(tren, 'Numar');
    final codStatieOrigine = elementAttributeValue(element, 'CodStaOrigine');
    // if (codStatieOrigine == '41092') {
    final vertexFound = createVertexFromNode(element, trainId);
    if (nodes.containsKey(codStatieOrigine)) {
      nodes[codStatieOrigine].add(vertexFound);
    } else {
      nodes[codStatieOrigine] = [vertexFound];
    }
    // }
  });
  return nodes;
}

Map<String, dynamic> createVertexFromNode(XmlElement traseu, String trainId) {
  final Map<String, dynamic> vertex = {};
  vertex['trainId'] = trainId;
  vertex['statieFinala'] = elementAttributeValue(traseu, 'CodStaDest');
  vertex['distanta'] = parseDistanta(elementAttributeValue(traseu, 'Km'));
  vertex['oraPornire'] = parseTime(elementAttributeValue(traseu, 'OraP'));
  vertex['oraSosire'] = parseTime(elementAttributeValue(traseu, 'OraS'));
  vertex['vitezaLivret'] =
      int.parse(elementAttributeValue(traseu, 'VitezaLivret'));
  return vertex;
}

Map<String, dynamic> decodeTren(XmlElement tren) {
  final Map<String, dynamic> trenJson = {};
  trenJson['id'] = tren.attributes[3].value;
  trenJson['categorie'] = tren.attributes[0].value;
  trenJson['traseu'] = decodeTraseu(tren.findAllElements('Trasa').first);
  trenJson['restrictii'] =
      decodeRestrictii(tren.findAllElements('RestrictiiTren').first);
  return trenJson;
}

Map<String, dynamic> decodeTraseu(XmlElement traseu) {
  final Map<String, dynamic> traseuJson = {};
  traseuJson['statieInitiala'] =
      elementAttributeValue(traseu, 'CodStatieInitiala');
  traseuJson['statieFinala'] = elementAttributeValue(traseu, 'CodStatieFinala');
  traseuJson['traseu'] = traseu
      .findAllElements('ElementTrasa')
      .map((e) => decodeElementTraseu(e))
      .toList();
  return traseuJson;
}

Map<String, dynamic> decodeElementTraseu(XmlElement elementTraseu) {
  final Map<String, dynamic> elementJson = {};
  elementJson['statieFinala'] =
      elementAttributeValue(elementTraseu, 'CodStaDest');
  elementJson['statieInitiala'] =
      elementAttributeValue(elementTraseu, 'CodStaOrigine');
  elementJson['distanta'] =
      parseDistanta(elementAttributeValue(elementTraseu, 'Km'));
  elementJson['oraPornire'] =
      parseTime(elementAttributeValue(elementTraseu, 'OraP'));
  elementJson['oraSosire'] =
      parseTime(elementAttributeValue(elementTraseu, 'OraS'));
  elementJson['vitezaLivret'] =
      int.parse(elementAttributeValue(elementTraseu, 'VitezaLivret'));
  return elementJson;
}

dynamic elementAttributeValue(XmlElement element, String attributeName) {
  return element.attributes
      .where((elemnt) => elemnt.name.toString() == attributeName)
      .first
      .value;
}

double parseDistanta(String distanta) {
  final intDecoded = int.parse(distanta);
  return intDecoded / 1000;
}

Map<String, dynamic> parseTime(String timestamp) {
  final intTimestamp = int.parse(timestamp);
  final hours = (intTimestamp / 3600).floor() % 24;
  final minutes = ((intTimestamp / 60) % 60).floor();
  return {
    'hours': hours,
    'minutes': minutes,
  };
}

List<Map<String, dynamic>> decodeRestrictii(XmlElement restrictii) {
  return restrictii.findAllElements('CalendarTren').map((e) {
    final deLa = e.attributes[0].value;
    final panaLa = e.attributes[2].value;
    return {
      'deLa': convertStringToDateTime(deLa),
      'panala': convertStringToDateTime(panaLa),
    };
  }).toList();
}

DateTime convertStringToDateTime(String data) {
  final year = int.parse(data.substring(0, 4));
  final month = int.parse(data.substring(4, 6));
  final day = int.parse(data.substring(6));
  return DateTime(year, month, day);
}
