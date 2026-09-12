// Removed geolocator
import '../../../../core/services/location/location_service.dart';
import '../../../../core/services/geocoding/geocoding_service.dart';
import '../../domain/entities/location_point.dart';
import '../../domain/repositories/location_repository.dart';

class LocationRepositoryImpl implements LocationRepository {
  final LocationService locationService;
  final GeocodingService geocodingService;

  LocationRepositoryImpl({
    required this.locationService,
    required this.geocodingService,
  });

  @override
  Future<bool> isLocationServiceEnabled() async {
    return await locationService.isLocationServiceEnabled();
  }

  @override
  Future<bool> checkPermission() async {
    final permission = await locationService.checkPermission();
    return permission == LocationPermission.always || permission == LocationPermission.whileInUse;
  }

  @override
  Future<bool> requestPermission() async {
    final permission = await locationService.requestPermission();
    return permission == LocationPermission.always || permission == LocationPermission.whileInUse;
  }

  @override
  Future<LocationPoint> getCurrentLocation() async {
    final position = await locationService.getCurrentPosition();
    return _mapPositionToLocationPoint(position);
  }

  @override
  Stream<LocationPoint> getLocationStream() {
    return locationService.getPositionStream().map((position) {
      return _mapPositionToLocationPoint(position);
    });
  }

  @override
  Future<String?> getAddressFromLocation(double latitude, double longitude) async {
    return await geocodingService.getAddressFromCoordinates(latitude, longitude);
  }

  LocationPoint _mapPositionToLocationPoint(Position position) {
    return LocationPoint(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.accuracy,
      altitude: position.altitude,
      speed: position.speed,
      timestamp: position.timestamp ?? DateTime.now(),
    );
  }
}
