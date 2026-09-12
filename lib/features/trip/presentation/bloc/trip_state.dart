import 'package:equatable/equatable.dart';
import '../../domain/entities/trip.dart';

abstract class TripState extends Equatable {
  const TripState();

  @override
  List<Object?> get props => [];
}

class TripInitial extends TripState {}

class TripLoading extends TripState {}

class TripLoaded extends TripState {
  final List<Trip> trips;

  const TripLoaded(this.trips);

  @override
  List<Object?> get props => [trips];
}

class TripDetailsLoaded extends TripState {
  final Trip selectedTrip;

  const TripDetailsLoaded(this.selectedTrip);

  @override
  List<Object?> get props => [selectedTrip];
}

class TripError extends TripState {
  final String message;

  const TripError(this.message);

  @override
  List<Object?> get props => [message];
}

class TripEmpty extends TripState {}

class TripOperationSuccess extends TripState {}
