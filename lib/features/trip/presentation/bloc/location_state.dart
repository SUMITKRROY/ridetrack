import 'package:equatable/equatable.dart';
import '../../domain/entities/location_point.dart';

abstract class LocationState extends Equatable {
  const LocationState();

  @override
  List<Object?> get props => [];
}

class LocationInitial extends LocationState {}

class LocationLoading extends LocationState {}

class LocationPermissionRequired extends LocationState {}

class LocationPermissionDenied extends LocationState {}

class LocationPermissionPermanentlyDenied extends LocationState {}

class LocationServiceDisabled extends LocationState {}

class LocationTracking extends LocationState {
  final String? tripId;
  final LocationPoint location;
  final String? address;
  final bool isTracking;
  final double distance; // in km
  final double maxSpeed; // in km/h
  final DateTime? startTime;
  final Duration duration;

  const LocationTracking({
    this.tripId,
    required this.location,
    this.address,
    required this.isTracking,
    this.distance = 0.0,
    this.maxSpeed = 0.0,
    this.startTime,
    this.duration = Duration.zero,
  });

  LocationTracking copyWith({
    String? tripId,
    LocationPoint? location,
    String? address,
    bool? isTracking,
    double? distance,
    double? maxSpeed,
    DateTime? startTime,
    Duration? duration,
  }) {
    return LocationTracking(
      tripId: tripId ?? this.tripId,
      location: location ?? this.location,
      address: address ?? this.address,
      isTracking: isTracking ?? this.isTracking,
      distance: distance ?? this.distance,
      maxSpeed: maxSpeed ?? this.maxSpeed,
      startTime: startTime ?? this.startTime,
      duration: duration ?? this.duration,
    );
  }

  @override
  List<Object?> get props => [
        tripId,
        location,
        address,
        isTracking,
        distance,
        maxSpeed,
        startTime,
        duration,
      ];
}

class LocationError extends LocationState {
  final String message;

  const LocationError(this.message);

  @override
  List<Object?> get props => [message];
}
