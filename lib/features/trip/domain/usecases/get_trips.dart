import '../entities/trip.dart';
import '../repositories/trip_repository.dart';

class GetTrips {
  final TripRepository repository;

  GetTrips({required this.repository});

  Future<List<Trip>> call() async {
    return await repository.getTrips();
  }
}
