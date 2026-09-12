import '../entities/trip.dart';
import '../repositories/trip_repository.dart';

class GetTripDetails {
  final TripRepository repository;

  GetTripDetails({required this.repository});

  Future<Trip?> call(String tripId) async {
    return await repository.getTripById(tripId);
  }
}
