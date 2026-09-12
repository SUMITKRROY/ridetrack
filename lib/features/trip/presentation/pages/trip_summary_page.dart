import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/trip.dart';

class TripSummaryPage extends StatelessWidget {
  const TripSummaryPage({super.key});

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
    final tripId = trip?.tripId ?? 'TRIP-1001';
    final distanceStr = '${trip?.distance.toStringAsFixed(2) ?? '0.00'} km';
    final durationStr = _calculateDuration(trip);
    final maxSpeedStr = '${trip?.maxSpeed.toStringAsFixed(1) ?? '0.0'} km/h';
    final startTimeStr = _formatTime(trip?.startTime);
    final endTimeStr = _formatTime(trip?.endTime);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Summary'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      size: 80,
                      color: AppColors.primaryGreen,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const Text(
                      'Trip Completed',
                      style: AppTextStyles.displayMedium,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    AppCard(
                      child: Column(
                        children: [
                          _buildSummaryRow('Trip ID', tripId),
                          const Divider(),
                          _buildSummaryRow('Distance', distanceStr),
                          const Divider(),
                          _buildSummaryRow('Duration', durationStr),
                          const Divider(),
                          _buildSummaryRow('Maximum Speed', maxSpeedStr),
                          const Divider(),
                          _buildSummaryRow('Start Time', startTimeStr),
                          const Divider(),
                          _buildSummaryRow('End Time', endTimeStr),
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
                text: 'DONE',
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.settings.name == AppRoutes.home);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
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
