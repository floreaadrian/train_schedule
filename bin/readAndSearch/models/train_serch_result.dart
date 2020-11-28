import 'package:equatable/equatable.dart';

import 'train.dart';

class TrainSearchResult extends Equatable {
  final Train train;
  final String sourceId;
  final String destinationId;

  TrainSearchResult(this.train, this.sourceId, this.destinationId);

  @override
  List<Object> get props => [train];

  @override
  bool get stringify => true;
}
