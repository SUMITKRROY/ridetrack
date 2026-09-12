import '../entities/location_point.dart';
import '../repositories/location_repository.dart';

class GetCurrentLocation {
  final LocationRepository repository;

  GetCurrentLocation({required this.repository});

  Future<LocationPoint> call() async {
    return await repository.getCurrentLocation();
  }
}
