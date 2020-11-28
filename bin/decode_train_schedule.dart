import 'readAndSearch/read.dart';
import 'xml_decode.dart';

void main(List<String> arguments) async {
  final paths = [
    'mers-tren-regio-calatori-2019-2020',
    'mers-tren-softrans-2019-2020',
    'mers-trenastra-trans-carpatic2019-2020',
    'mers-trencalea-ferata-din-moldova2019-2020',
    'mers-treninterregional2019-2020',
    'mers-trensntfc2019-2020',
    'mers-trentransferoviar-calatori-2019-2020',
  ];
  // paths.forEach((element) => decode(element));
  paths.forEach((element) => readFromFile(element));
}
