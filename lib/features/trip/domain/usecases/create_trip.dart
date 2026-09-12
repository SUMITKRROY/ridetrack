import '../entities/trip.dart';
import '../repositories/trip_repository.dart';

class CreateTrip {
  final TripRepository repository;

  CreateTrip({required this.repository});

  Future<void> call(Trip trip) async {
    return await repository.createTrip(trip);
  }
}
