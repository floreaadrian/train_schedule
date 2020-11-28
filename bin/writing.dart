import 'dart:convert';
import 'dart:io';

Future<File> _createFile(String filename) {
  return File('${Directory.current.path}/res/output/graph/${filename}.json')
      .create(recursive: true);
}

Future<File> _localFile(String filename) async {
  if (File('${Directory.current.path}/res/output/graph/${filename}.json')
      .existsSync()) {
    return File('${Directory.current.path}/res/output/graph/${filename}.json');
  } else {
    return _createFile(filename);
  }
}

Future<File> writeCounter(Map<String, dynamic> data, String fileName) async {
  final file = await _localFile(fileName);
  return file.writeAsString(
    jsonEncode(data, toEncodable: _myEncode),
    mode: FileMode.append,
  );
}

dynamic _myEncode(dynamic item) {
  if (item is DateTime) {
    return item.toIso8601String();
  }
  return item;
}
