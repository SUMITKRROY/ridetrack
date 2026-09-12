import 'dart:convert';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'geocoding_service.dart';

class GeocodingServiceImpl implements GeocodingService {
  @override
  Future<String?> getAddressFromCoordinates(double latitude, double longitude) async {
    // 1. Try native platform geocoding (Google Play Services / iOS CLGeocoder)
    try {
      final placemarks = await Geocoding().placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final parts = <String>[
          if (place.street != null && place.street!.trim().isNotEmpty) place.street!.trim(),
          if (place.subLocality != null && place.subLocality!.trim().isNotEmpty) place.subLocality!.trim(),
          if (place.locality != null && place.locality!.trim().isNotEmpty) place.locality!.trim(),
          if (place.administrativeArea != null && place.administrativeArea!.trim().isNotEmpty) place.administrativeArea!.trim(),
          if (place.postalCode != null && place.postalCode!.trim().isNotEmpty) place.postalCode!.trim(),
        ];
        if (parts.isNotEmpty) {
          return parts.toSet().join(', ');
        }
      }
    } catch (_) {}

    // 2. Fallback to OpenStreetMap reverse geocoding
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?lat=$latitude&lon=$longitude&format=json',
      );
      final response = await http.get(
        url,
        headers: {'User-Agent': 'KSKTRiderApp/1.0'},
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map && data['display_name'] != null) {
          final displayName = data['display_name'] as String;
          // Trim display name if too long
          final segments = displayName.split(', ');
          if (segments.length > 3) {
            return segments.take(3).join(', ');
          }
          return displayName;
        }
      }
    } catch (_) {}

    // 3. Fallback to formatted coordinates if network/geocoder is unavailable
    return 'Lat: ${latitude.toStringAsFixed(4)}, Lng: ${longitude.toStringAsFixed(4)}';
  }
}
