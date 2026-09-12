import '../entities/location_point.dart';
import '../repositories/location_repository.dart';

class GetLocationStream {
  final LocationRepository repository;

  GetLocationStream({required this.repository});

  Stream<LocationPoint> call() {
    return repository.getLocationStream();
  }
}
