import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../bloc/location_bloc.dart';
import '../bloc/location_event.dart';
import '../bloc/location_state.dart';
import '../widgets/rider_map.dart';

import '../../domain/entities/trip.dart';
import '../bloc/trip_bloc.dart';
import '../bloc/trip_event.dart';
import '../bloc/trip_state.dart';

class ActiveTripPage extends StatefulWidget {
  const ActiveTripPage({super.key});

  @override
  State<ActiveTripPage> createState() => _ActiveTripPageState();
}

class _ActiveTripPageState extends State<ActiveTripPage> {
  late final String _tripId;
  late final String _startTime;

  @override
  void initState() {
    super.initState();
    final locState = context.read<LocationBloc>().state;
    if (locState is LocationTracking && locState.isTracking && locState.tripId != null) {
      _tripId = locState.tripId!;
      _startTime = locState.startTime?.toIso8601String() ?? DateTime.now().toIso8601String();
    } else {
      final tripState = context.read<TripBloc>().state;
      Trip? existingOngoing;
      if (tripState is TripLoaded) {
        for (final t in tripState.trips) {
          if (t.status.toLowerCase() == 'ongoing') {
            existingOngoing = t;
            break;
          }
        }
      }

      if (existingOngoing != null) {
        _tripId = existingOngoing.tripId;
        _startTime = existingOngoing.startTime;
        final startDt = DateTime.tryParse(existingOngoing.startTime) ?? DateTime.now();
        context.read<LocationBloc>().add(StartLocationTracking(
          tripId: existingOngoing.tripId,
          startTime: startDt,
          initialDistance: existingOngoing.distance,
          initialMaxSpeed: existingOngoing.maxSpeed,
        ));
      } else {
        _tripId = 'TRIP-${DateTime.now().millisecondsSinceEpoch % 100000}';
        _startTime = DateTime.now().toIso8601String();

        final initialTrip = Trip(
          tripId: _tripId,
          status: 'ongoing',
          startTime: _startTime,
          distance: 0.0,
          currentSpeed: 0.0,
          maxSpeed: 0.0,
          createdAt: _startTime,
          updatedAt: _startTime,
        );

        context.read<TripBloc>().add(CreateTripEvent(initialTrip));
        context.read<LocationBloc>().add(StartLocationTracking(tripId: _tripId));
      }
    }
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours.toString().padLeft(2, '0');
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TRIP ACTIVE'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back to Home',
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: AppColors.lightGreen,
        centerTitle: true,
      ),
      body: SafeArea(
        child: BlocBuilder<LocationBloc, LocationState>(
          builder: (context, state) {
            if (state is LocationInitial || state is LocationLoading) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: AppColors.primaryGreen),
                    SizedBox(height: AppSpacing.md),
                    Text('Acquiring GPS Signal...'),
                  ],
                ),
              );
            }

            if (state is LocationServiceDisabled) {
              return _buildErrorState('Location services are disabled.\nPlease enable GPS in your device settings.');
            }

            if (state is LocationPermissionDenied || state is LocationPermissionPermanentlyDenied) {
              return _buildErrorState('Location permission denied.\nPlease allow access in settings to continue.');
            }

            if (state is LocationError) {
              return _buildErrorState('Error: ${state.message}');
            }

            if (state is LocationTracking) {
              return _buildTrackingUI(context, state);
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.location_off, size: 64, color: AppColors.orange),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackingUI(BuildContext context, LocationTracking state) {
    final location = state.location;
    final speedKmH = (location.speed * 3.6).toStringAsFixed(1);
    final accuracyStr = location.accuracy.toStringAsFixed(1);
    final latStr = location.latitude.toStringAsFixed(5);
    final lngStr = location.longitude.toStringAsFixed(5);
    final address = state.address ?? 'Detecting actual address...';

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                // Large map
                Container(
                  width: double.infinity,
                  height: 250,
                  decoration: BoxDecoration(
                    color: AppColors.lightGreen,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: AppColors.primaryGreen.withOpacity(0.3)),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: RiderMap(state: state),
                ),
                const SizedBox(height: AppSpacing.md),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: AppColors.primaryGreen.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, color: AppColors.primaryGreen, size: 22),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          address,
                          style: AppTextStyles.titleMedium.copyWith(
                            color: AppColors.darkGreen,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppCard(
                  child: Column(
                    children: [
                      const Text('Current Speed', style: AppTextStyles.bodyLarge),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        speedKmH,
                        style: AppTextStyles.displayLarge.copyWith(
                          fontSize: 64,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                      const Text('km/h', style: AppTextStyles.bodyMedium),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(child: _buildMetricCard('Distance', '${state.distance.toStringAsFixed(2)} km')),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(child: _buildMetricCard('Maximum Speed', '${state.maxSpeed.toStringAsFixed(1)} km/h')),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(child: _buildMetricCard('Duration', _formatDuration(state.duration))),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(child: _buildMetricCard('GPS Accuracy', '$accuracyStr m')),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Current Coordinates', style: AppTextStyles.titleMedium),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Latitude:', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.greyText)),
                          Text(latStr, style: AppTextStyles.bodyLarge),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Longitude:', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.greyText)),
                          Text(lngStr, style: AppTextStyles.bodyLarge),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: PrimaryButton(
            text: 'END TRIP',
            onPressed: () {
              final currentTrip = Trip(
                tripId: _tripId,
                status: 'ongoing',
                startTime: _startTime,
                distance: double.parse(state.distance.toStringAsFixed(2)),
                currentSpeed: double.parse(speedKmH),
                maxSpeed: double.parse(state.maxSpeed.toStringAsFixed(1)),
                latitude: location.latitude,
                longitude: location.longitude,
                accuracy: location.accuracy,
                createdAt: _startTime,
                updatedAt: DateTime.now().toIso8601String(),
              );
              Navigator.of(context).pushNamed(
                AppRoutes.endTrip,
                arguments: currentTrip,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.greyText)),
          const SizedBox(height: AppSpacing.xs),
          Text(value, style: AppTextStyles.titleLarge),
        ],
      ),
    );
  }
}
