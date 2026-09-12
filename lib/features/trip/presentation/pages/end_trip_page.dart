import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/secondary_button.dart';
import '../../domain/entities/trip.dart';
import '../bloc/location_bloc.dart';
import '../bloc/location_event.dart';
import '../bloc/trip_bloc.dart';
import '../bloc/trip_event.dart';

class EndTripPage extends StatelessWidget {
  const EndTripPage({super.key});

  String _formatDuration(String? startTimeStr) {
    if (startTimeStr == null) return '00:00:00';
    try {
      final start = DateTime.parse(startTimeStr);
      final diff = DateTime.now().difference(start);
      final hours = diff.inHours.toString().padLeft(2, '0');
      final minutes = diff.inMinutes.remainder(60).toString().padLeft(2, '0');
      final seconds = diff.inSeconds.remainder(60).toString().padLeft(2, '0');
      return '$hours:$minutes:$seconds';
    } catch (_) {
      return '00:00:00';
    }
  }

  @override
  Widget build(BuildContext context) {
    final trip = ModalRoute.of(context)?.settings.arguments as Trip?;
    final distanceStr = '${trip?.distance.toStringAsFixed(2) ?? '0.00'} km';
    final durationStr = _formatDuration(trip?.startTime);
    final speedStr = '${trip?.currentSpeed.toStringAsFixed(1) ?? '0.0'} km/h';

    return Scaffold(
      appBar: AppBar(
        title: const Text('End Trip'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                size: 80,
                color: AppColors.orange,
              ),
              const SizedBox(height: AppSpacing.xl),
              const Text(
                'End Current Trip?',
                style: AppTextStyles.displayMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              const Text(
                'Are you sure you want to end your current trip?',
                style: AppTextStyles.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xxl),
              _buildStatRow('Distance', distanceStr),
              const Divider(height: AppSpacing.xl),
              _buildStatRow('Duration', durationStr),
              const Divider(height: AppSpacing.xl),
              _buildStatRow('Current Speed', speedStr),
              const Spacer(),
              SecondaryButton(
                text: 'Continue Trip',
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              const SizedBox(height: AppSpacing.md),
              PrimaryButton(
                text: 'End Trip',
                onPressed: () {
                  context.read<LocationBloc>().add(StopLocationTracking());

                  final now = DateTime.now().toIso8601String();
                  final completedTrip = trip != null
                      ? Trip(
                          tripId: trip.tripId,
                          status: 'completed',
                          startTime: trip.startTime,
                          endTime: now,
                          distance: trip.distance,
                          currentSpeed: 0.0,
                          maxSpeed: trip.maxSpeed,
                          latitude: trip.latitude,
                          longitude: trip.longitude,
                          accuracy: trip.accuracy,
                          createdAt: trip.createdAt,
                          updatedAt: now,
                        )
                      : Trip(
                          tripId: 'TRIP-${DateTime.now().millisecondsSinceEpoch % 100000}',
                          status: 'completed',
                          startTime: now,
                          endTime: now,
                          distance: 0.0,
                          currentSpeed: 0.0,
                          maxSpeed: 0.0,
                          createdAt: now,
                          updatedAt: now,
                        );

                  context.read<TripBloc>().add(UpdateTripEvent(completedTrip));

                  // Navigate directly to Home and show updated overview
                  Future.delayed(const Duration(milliseconds: 150), () {
                    if (context.mounted) {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        AppRoutes.home,
                        (route) => false,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Trip ${completedTrip.tripId} completed and saved!'),
                          backgroundColor: AppColors.primaryGreen,
                        ),
                      );
                    }
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyLarge.copyWith(color: AppColors.greyText)),
        Text(value, style: AppTextStyles.titleLarge),
      ],
    );
  }
}
