abstract class GeocodingService {
  Future<String?> getAddressFromCoordinates(double latitude, double longitude);
}
