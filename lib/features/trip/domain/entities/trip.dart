class Trip {
  final String tripId;
  final String status;
  final String startTime;
  final String? endTime;
  final double distance;
  final double currentSpeed;
  final double maxSpeed;
  final double? latitude;
  final double? longitude;
  final double? accuracy;
  final String createdAt;
  final String updatedAt;

  const Trip({
    required this.tripId,
    required this.status,
    required this.startTime,
    this.endTime,
    required this.distance,
    required this.currentSpeed,
    required this.maxSpeed,
    this.latitude,
    this.longitude,
    this.accuracy,
    required this.createdAt,
    required this.updatedAt,
  });
}
