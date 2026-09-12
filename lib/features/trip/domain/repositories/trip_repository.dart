import '../entities/trip.dart';

abstract class TripRepository {
  Future<List<Trip>> getTrips();
  Future<Trip?> getTripById(String tripId);
  Future<void> createTrip(Trip trip);
  Future<void> updateTrip(Trip trip);
  Future<void> insertDummyData();
}
