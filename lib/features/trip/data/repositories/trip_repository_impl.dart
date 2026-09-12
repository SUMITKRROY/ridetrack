import '../../domain/entities/trip.dart';
import '../../domain/repositories/trip_repository.dart';
import '../datasources/trip_local_datasource.dart';
import '../models/trip_model.dart';

class TripRepositoryImpl implements TripRepository {
  final TripLocalDataSource localDataSource;

  TripRepositoryImpl({required this.localDataSource});

  @override
  Future<List<Trip>> getTrips() async {
    return await localDataSource.getTrips();
  }

  @override
  Future<Trip?> getTripById(String tripId) async {
    return await localDataSource.getTripById(tripId);
  }

  @override
  Future<void> createTrip(Trip trip) async {
    final tripModel = TripModel.fromEntity(trip);
    await localDataSource.insertTrip(tripModel);
  }

  @override
  Future<void> updateTrip(Trip trip) async {
    final tripModel = TripModel.fromEntity(trip);
    await localDataSource.updateTrip(tripModel);
  }

  @override
  Future<void> insertDummyData() async {
    await localDataSource.insertDummyData();
  }
}
