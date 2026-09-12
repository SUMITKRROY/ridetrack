import '../../../../core/database/tables/trip_table.dart';
import '../../domain/entities/trip.dart';

class TripModel extends Trip {
  const TripModel({
    required super.tripId,
    required super.status,
    required super.startTime,
    super.endTime,
    required super.distance,
    required super.currentSpeed,
    required super.maxSpeed,
    super.latitude,
    super.longitude,
    super.accuracy,
    required super.createdAt,
    required super.updatedAt,
  });

  factory TripModel.fromMap(Map<String, dynamic> map) {
    return TripModel(
      tripId: map[TripTable.tripId] as String,
      status: map[TripTable.status] as String,
      startTime: map[TripTable.startTime] as String,
      endTime: map[TripTable.endTime] as String?,
      distance: (map[TripTable.distance] as num).toDouble(),
      currentSpeed: (map[TripTable.currentSpeed] as num).toDouble(),
      maxSpeed: (map[TripTable.maxSpeed] as num).toDouble(),
      latitude: map[TripTable.latitude] != null ? (map[TripTable.latitude] as num).toDouble() : null,
      longitude: map[TripTable.longitude] != null ? (map[TripTable.longitude] as num).toDouble() : null,
      accuracy: map[TripTable.accuracy] != null ? (map[TripTable.accuracy] as num).toDouble() : null,
      createdAt: map[TripTable.createdAt] as String,
      updatedAt: map[TripTable.updatedAt] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      TripTable.tripId: tripId,
      TripTable.status: status,
      TripTable.startTime: startTime,
      TripTable.endTime: endTime,
      TripTable.distance: distance,
      TripTable.currentSpeed: currentSpeed,
      TripTable.maxSpeed: maxSpeed,
      TripTable.latitude: latitude,
      TripTable.longitude: longitude,
      TripTable.accuracy: accuracy,
      TripTable.createdAt: createdAt,
      TripTable.updatedAt: updatedAt,
    };
  }

  factory TripModel.fromEntity(Trip trip) {
    return TripModel(
      tripId: trip.tripId,
      status: trip.status,
      startTime: trip.startTime,
      endTime: trip.endTime,
      distance: trip.distance,
      currentSpeed: trip.currentSpeed,
      maxSpeed: trip.maxSpeed,
      latitude: trip.latitude,
      longitude: trip.longitude,
      accuracy: trip.accuracy,
      createdAt: trip.createdAt,
      updatedAt: trip.updatedAt,
    );
  }
}
