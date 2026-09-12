import '../entities/trip.dart';
import '../repositories/trip_repository.dart';

class UpdateTrip {
  final TripRepository repository;

  UpdateTrip({required this.repository});

  Future<void> call(Trip trip) async {
    return await repository.updateTrip(trip);
  }
}
