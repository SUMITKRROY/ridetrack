import 'dart:async';
import 'dart:math' as math;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_current_location.dart';
import '../../domain/usecases/get_location_stream.dart';
import '../../domain/usecases/get_address_from_location.dart';
import '../../domain/repositories/location_repository.dart';
import '../../data/datasources/trip_local_datasource.dart';
import '../../data/models/trip_model.dart';
import 'location_event.dart';
import 'location_state.dart';
import '../../domain/entities/location_point.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  final LocationRepository repository;
  final GetCurrentLocation getCurrentLocation;
  final GetLocationStream getLocationStream;
  final GetAddressFromLocation getAddressFromLocation;
  final TripLocalDataSource? tripLocalDataSource;

  StreamSubscription<LocationPoint>? _locationSubscription;
  Timer? _durationTimer;
  LocationPoint? _lastGeocodedLocation;
  LocationPoint? _lastLocationPoint;
  DateTime? _lastPersistedAt;

  String? _tripId;
  DateTime? _startTime;
  double _distance = 0.0; // km
  double _maxSpeed = 0.0; // km/h

  LocationBloc({
    required this.repository,
    required this.getCurrentLocation,
    required this.getLocationStream,
    required this.getAddressFromLocation,
    this.tripLocalDataSource,
  }) : super(LocationInitial()) {
    on<StartLocationTracking>(_onStartLocationTracking);
    on<StopLocationTracking>(_onStopLocationTracking);
    on<LocationUpdated>(_onLocationUpdated);
    on<AddressUpdated>(_onAddressUpdated);
    on<LocationTimerTicked>(_onLocationTimerTicked);
  }

  Future<void> _onStartLocationTracking(StartLocationTracking event, Emitter<LocationState> emit) async {
    emit(LocationLoading());

    try {
      final isServiceEnabled = await repository.isLocationServiceEnabled();
      if (!isServiceEnabled) {
        emit(LocationServiceDisabled());
        return;
      }

      final isPermissionGranted = await repository.checkPermission();
      if (!isPermissionGranted) {
        final requestResult = await repository.requestPermission();
        if (!requestResult) {
          emit(LocationPermissionDenied());
          return;
        }
      }

      // Initialize trip tracking metrics (or restore ongoing)
      _tripId = event.tripId;
      _startTime = event.startTime ?? DateTime.now();
      _distance = event.initialDistance;
      _maxSpeed = event.initialMaxSpeed;
      _lastLocationPoint = null;
      _lastGeocodedLocation = null;
      _lastPersistedAt = null;

      // Start duration timer ticking every second
      _durationTimer?.cancel();
      _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (_startTime != null) {
          final elapsed = DateTime.now().difference(_startTime!);
          add(LocationTimerTicked(elapsed));
        }
      });

      // Initial location
      final location = await getCurrentLocation();
      add(LocationUpdated(location));

      // Start listening to stream
      _locationSubscription?.cancel();
      _locationSubscription = getLocationStream().listen(
        (location) => add(LocationUpdated(location)),
        onError: (error) => emit(LocationError(error.toString())),
      );
    } catch (e) {
      emit(LocationError(e.toString()));
    }
  }

  Future<void> _onLocationUpdated(LocationUpdated event, Emitter<LocationState> emit) async {
    // Basic validation (skip inaccurate locations)
    if (event.location.accuracy > 50) return;

    final currentSpeedKmH = event.location.speed * 3.6;
    if (currentSpeedKmH > _maxSpeed) {
      _maxSpeed = currentSpeedKmH;
    }

    if (_lastLocationPoint != null) {
      final meters = _calculateHaversineDistance(
        _lastLocationPoint!.latitude,
        _lastLocationPoint!.longitude,
        event.location.latitude,
        event.location.longitude,
      );
      // Filter out micro-jitters (< 2 meters) or erroneous jumps (> 5 km in one update)
      if (meters >= 2.0 && meters < 5000.0) {
        _distance += (meters / 1000.0);
      }
    }
    _lastLocationPoint = event.location;

    String? currentAddress;
    if (state is LocationTracking) {
      final currentState = state as LocationTracking;
      currentAddress = currentState.address;
    }

    final duration = _startTime != null
        ? DateTime.now().difference(_startTime!)
        : Duration.zero;

    emit(LocationTracking(
      tripId: _tripId,
      location: event.location,
      address: currentAddress,
      isTracking: true,
      distance: _distance,
      maxSpeed: _maxSpeed,
      startTime: _startTime,
      duration: duration,
    ));

    _checkGeocoding(event.location);
    _persistOngoingTrip(event.location);
  }

  void _persistOngoingTrip(LocationPoint location) {
    if (_tripId == null || tripLocalDataSource == null || _startTime == null) return;
    final now = DateTime.now();
    if (_lastPersistedAt != null && now.difference(_lastPersistedAt!).inSeconds < 5) {
      return;
    }
    _lastPersistedAt = now;
    final tripModel = TripModel(
      tripId: _tripId!,
      status: 'ongoing',
      startTime: _startTime!.toIso8601String(),
      distance: double.parse(_distance.toStringAsFixed(2)),
      currentSpeed: double.parse((location.speed * 3.6).toStringAsFixed(1)),
      maxSpeed: double.parse(_maxSpeed.toStringAsFixed(1)),
      latitude: location.latitude,
      longitude: location.longitude,
      accuracy: location.accuracy,
      createdAt: _startTime!.toIso8601String(),
      updatedAt: now.toIso8601String(),
    );
    tripLocalDataSource!.updateTrip(tripModel);
  }

  void _onLocationTimerTicked(LocationTimerTicked event, Emitter<LocationState> emit) {
    if (state is LocationTracking) {
      final currentState = state as LocationTracking;
      emit(currentState.copyWith(duration: event.duration));
    }
  }

  Future<void> _onAddressUpdated(AddressUpdated event, Emitter<LocationState> emit) async {
    if (state is LocationTracking) {
      final currentState = state as LocationTracking;
      emit(currentState.copyWith(address: event.address));
    }
  }

  Future<void> _checkGeocoding(LocationPoint location) async {
    if (_lastGeocodedLocation == null ||
        _calculateHaversineDistance(
              _lastGeocodedLocation!.latitude,
              _lastGeocodedLocation!.longitude,
              location.latitude,
              location.longitude,
            ) > 100) {
      _lastGeocodedLocation = location;
      final address = await getAddressFromLocation(location.latitude, location.longitude);
      if (address != null) {
        add(AddressUpdated(address));
      }
    }
  }

  double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180.0);
  }

  double _calculateHaversineDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371000.0; // meters
    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);
    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) *
            math.cos(_degreesToRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  Future<void> _onStopLocationTracking(StopLocationTracking event, Emitter<LocationState> emit) async {
    _durationTimer?.cancel();
    _durationTimer = null;
    await _locationSubscription?.cancel();
    _locationSubscription = null;
    if (state is LocationTracking) {
      final currentState = state as LocationTracking;
      emit(currentState.copyWith(isTracking: false));
    }
  }

  @override
  Future<void> close() {
    _durationTimer?.cancel();
    _locationSubscription?.cancel();
    return super.close();
  }
}
