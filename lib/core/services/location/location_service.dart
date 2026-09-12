enum LocationPermission {
  denied,
  deniedForever,
  whileInUse,
  always,
}

class Position {
  final double latitude;
  final double longitude;
  final double accuracy;
  final double altitude;
  final double speed;
  final DateTime? timestamp;

  Position({
    required this.latitude,
    required this.longitude,
    this.accuracy = 0.0,
    this.altitude = 0.0,
    this.speed = 0.0,
    this.timestamp,
  });
}

abstract class LocationService {
  Future<bool> isLocationServiceEnabled();
  Future<LocationPermission> checkPermission();
  Future<LocationPermission> requestPermission();
  Future<Position> getCurrentPosition();
  Stream<Position> getPositionStream();
}
