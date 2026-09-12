import 'package:equatable/equatable.dart';
import '../../domain/entities/location_point.dart';

abstract class LocationEvent extends Equatable {
  const LocationEvent();

  @override
  List<Object?> get props => [];
}

class StartLocationTracking extends LocationEvent {
  final String? tripId;
  final DateTime? startTime;
  final double initialDistance;
  final double initialMaxSpeed;

  const StartLocationTracking({
    this.tripId,
    this.startTime,
    this.initialDistance = 0.0,
    this.initialMaxSpeed = 0.0,
  });

  @override
  List<Object?> get props => [tripId, startTime, initialDistance, initialMaxSpeed];
}

class StopLocationTracking extends LocationEvent {}

class LocationUpdated extends LocationEvent {
  final LocationPoint location;

  const LocationUpdated(this.location);

  @override
  List<Object?> get props => [location];
}

class AddressUpdated extends LocationEvent {
  final String address;

  const AddressUpdated(this.address);

  @override
  List<Object?> get props => [address];
}

class LocationTimerTicked extends LocationEvent {
  final Duration duration;

  const LocationTimerTicked(this.duration);

  @override
  List<Object?> get props => [duration];
}

