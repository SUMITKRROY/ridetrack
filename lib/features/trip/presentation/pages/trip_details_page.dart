import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';

import '../../domain/entities/trip.dart';

class TripDetailsPage extends StatelessWidget {
  const TripDetailsPage({super.key});

  String _formatTime(String? isoString) {
    if (isoString == null) return '--:--';
    try {
      final dt = DateTime.parse(isoString).toLocal();
      final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final minute = dt.minute.toString().padLeft(2, '0');
      final period = dt.hour >= 12 ? 'PM' : 'AM';
      return '$hour:$minute $period';
    } catch (_) {
      return isoString;
    }
  }

  String _calculateDuration(Trip? trip) {
    if (trip == null) return '00:00:00';
    if (trip.endTime != null && trip.endTime!.isNotEmpty) {
      try {
        final s = DateTime.parse(trip.startTime);
        final e = DateTime.parse(trip.endTime!);
        final diff = e.difference(s);
        if (!diff.isNegative) {
          final hours = diff.inHours.toString().padLeft(2, '0');
          final minutes = diff.inMinutes.remainder(60).toString().padLeft(2, '0');
          final seconds = diff.inSeconds.remainder(60).toString().padLeft(2, '0');
          return '$hours:$minutes:$seconds';
        }
      } catch (_) {}
    }
    if (trip.status.toLowerCase() == 'ongoing') {
      try {
        final s = DateTime.parse(trip.startTime);
        final diff = DateTime.now().difference(s);
        final hours = diff.inHours.toString().padLeft(2, '0');
        final minutes = diff.inMinutes.remainder(60).toString().padLeft(2, '0');
        final seconds = diff.inSeconds.remainder(60).toString().padLeft(2, '0');
        return '$hours:$minutes:$seconds';
      } catch (_) {}
    }
    if (trip.distance > 0) {
      final approxSpeedKmh = trip.maxSpeed > 0 ? (trip.maxSpeed * 0.55).clamp(20.0, 60.0) : 35.0;
      final approxSeconds = ((trip.distance / approxSpeedKmh) * 3600).round();
      final diff = Duration(seconds: approxSeconds);
      final hours = diff.inHours.toString().padLeft(2, '0');
      final minutes = diff.inMinutes.remainder(60).toString().padLeft(2, '0');
      final seconds = diff.inSeconds.remainder(60).toString().padLeft(2, '0');
      return '$hours:$minutes:$seconds';
    }
    return '00:00:00';
  }

  @override
  Widget build(BuildContext context) {
    final trip = ModalRoute.of(context)?.settings.arguments as Trip?;
    final tripId = trip?.tripId ?? 'TRIP-1002';
    final status = (trip?.status ?? 'Completed').toUpperCase();
    final distance = '${trip?.distance.toStringAsFixed(2) ?? '0.00'} km';
    final duration = _calculateDuration(trip);
    final maxSpeed = '${trip?.maxSpeed.toStringAsFixed(1) ?? '0.0'} km/h';
    final startTime = _formatTime(trip?.startTime);
    final endTime = _formatTime(trip?.endTime);
    final coords = trip?.latitude != null && trip?.longitude != null
        ? '${trip!.latitude!.toStringAsFixed(4)}, ${trip.longitude!.toStringAsFixed(4)}'
        : 'Not recorded';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Details'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tripId,
                style: AppTextStyles.displayMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(status, style: AppTextStyles.titleMedium.copyWith(color: AppColors.primaryGreen)),
              const SizedBox(height: AppSpacing.xl),
              AppCard(
                child: Column(
                  children: [
                    _buildDetailRow('Distance', distance),
                    const Divider(),
                    _buildDetailRow('Duration', duration),
                    const Divider(),
                    _buildDetailRow('Max Speed', maxSpeed),
                    const Divider(),
                    _buildDetailRow('Start Time', startTime),
                    const Divider(),
                    _buildDetailRow('End Time', endTime),
                    const Divider(),
                    _buildDetailRow('Coordinates', coords),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyLarge.copyWith(color: AppColors.greyText)),
          Text(value, style: AppTextStyles.titleMedium),
        ],
      ),
    );
  }
}
