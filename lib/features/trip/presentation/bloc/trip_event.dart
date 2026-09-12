import 'package:equatable/equatable.dart';
import '../../domain/entities/trip.dart';

abstract class TripEvent extends Equatable {
  const TripEvent();

  @override
  List<Object?> get props => [];
}

class LoadTrips extends TripEvent {}

class CreateTripEvent extends TripEvent {
  final Trip trip;

  const CreateTripEvent(this.trip);

  @override
  List<Object?> get props => [trip];
}

class UpdateTripEvent extends TripEvent {
  final Trip trip;

  const UpdateTripEvent(this.trip);

  @override
  List<Object?> get props => [trip];
}

class LoadTripDetails extends TripEvent {
  final String tripId;

  const LoadTripDetails(this.tripId);

  @override
  List<Object?> get props => [tripId];
}

class RefreshTrips extends TripEvent {}

class SeedDummyTripsEvent extends TripEvent {}
