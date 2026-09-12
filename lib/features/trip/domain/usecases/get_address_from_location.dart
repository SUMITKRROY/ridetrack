import '../repositories/location_repository.dart';

class GetAddressFromLocation {
  final LocationRepository repository;

  GetAddressFromLocation({required this.repository});

  Future<String?> call(double latitude, double longitude) async {
    return await repository.getAddressFromLocation(latitude, longitude);
  }
}
