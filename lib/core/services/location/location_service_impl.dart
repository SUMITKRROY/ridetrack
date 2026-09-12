import 'dart:async';
import 'package:geolocator/geolocator.dart' as geo;
import 'location_service.dart';

class LocationServiceImpl implements LocationService {
  @override
  Future<bool> isLocationServiceEnabled() async {
    return await geo.Geolocator.isLocationServiceEnabled();
  }

  @override
  Future<LocationPermission> checkPermission() async {
    final permission = await geo.Geolocator.checkPermission();
    return _mapPermission(permission);
  }

  @override
  Future<LocationPermission> requestPermission() async {
    final permission = await geo.Geolocator.requestPermission();
    return _mapPermission(permission);
  }

  @override
  Future<Position> getCurrentPosition() async {
    try {
      final pos = await geo.Geolocator.getCurrentPosition(
        locationSettings: const geo.LocationSettings(
          accuracy: geo.LocationAccuracy.high,
          timeLimit: Duration(seconds: 8),
        ),
      );
      return _mapPosition(pos);
    } catch (_) {
      final lastPos = await geo.Geolocator.getLastKnownPosition();
      if (lastPos != null) {
        return _mapPosition(lastPos);
      }
      rethrow;
    }
  }

  @override
  Stream<Position> getPositionStream() {
    const locationSettings = geo.LocationSettings(
      accuracy: geo.LocationAccuracy.high,
      distanceFilter: 2,
    );
    return geo.Geolocator.getPositionStream(locationSettings: locationSettings)
        .map(_mapPosition);
  }

  LocationPermission _mapPermission(geo.LocationPermission permission) {
    switch (permission) {
      case geo.LocationPermission.denied:
      case geo.LocationPermission.unableToDetermine:
        return LocationPermission.denied;
      case geo.LocationPermission.deniedForever:
        return LocationPermission.deniedForever;
      case geo.LocationPermission.whileInUse:
        return LocationPermission.whileInUse;
      case geo.LocationPermission.always:
        return LocationPermission.always;
    }
  }

  Position _mapPosition(geo.Position pos) {
    return Position(
      latitude: pos.latitude,
      longitude: pos.longitude,
      accuracy: pos.accuracy,
      altitude: pos.altitude,
      speed: pos.speed,
      timestamp: pos.timestamp,
    );
  }
}
