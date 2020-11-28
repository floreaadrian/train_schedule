import 'package:equatable/equatable.dart';

class Train extends Equatable {
  final String id;
  final List<Stop> stops;
  final String trainCompany;
  final String category;

  Train(this.id, this.stops, this.trainCompany, this.category);

  @override
  List<Object> get props => [id, stops, trainCompany, category];

  @override
  bool get stringify => true;
}

class Stop extends Equatable {
  final String stationId;
  final int vitezaLivret;
  final double distanceNext;
  final String timeStart;
  final String timeArriveNext;

  Stop(
    this.stationId,
    this.timeStart,
    this.timeArriveNext,
    this.vitezaLivret,
    this.distanceNext,
  );

  @override
  List<Object> get props => [stationId, timeStart, timeArriveNext];

  @override
  bool get stringify => true;
}
