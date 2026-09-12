import '../repositories/trip_repository.dart';

class SeedDummyTrips {
  final TripRepository repository;

  SeedDummyTrips({required this.repository});

  Future<void> call() async {
    return await repository.insertDummyData();
  }
}
