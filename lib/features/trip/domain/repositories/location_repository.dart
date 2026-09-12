import '../entities/location_point.dart';

abstract class LocationRepository {
  Future<bool> isLocationServiceEnabled();
  Future<bool> checkPermission();
  Future<bool> requestPermission();
  Future<LocationPoint> getCurrentLocation();
  Stream<LocationPoint> getLocationStream();
  Future<String?> getAddressFromLocation(double latitude, double longitude);
}
