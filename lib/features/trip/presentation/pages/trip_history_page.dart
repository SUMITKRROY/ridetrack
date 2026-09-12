import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/app_card.dart';
import '../bloc/trip_bloc.dart';
import '../bloc/trip_event.dart';
import '../bloc/trip_state.dart';
import '../../domain/entities/trip.dart';

class TripHistoryPage extends StatefulWidget {
  const TripHistoryPage({super.key});

  @override
  State<TripHistoryPage> createState() => _TripHistoryPageState();
}

class _TripHistoryPageState extends State<TripHistoryPage> {
  @override
  void initState() {
    super.initState();
    final tripBloc = context.read<TripBloc>();
    // First seed data if empty, then load trips.
    tripBloc.add(SeedDummyTripsEvent());
    tripBloc.add(LoadTrips());
  }

  String _calculateDuration(Trip trip) {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<TripBloc>().add(RefreshTrips()),
          ),
        ],
      ),
      body: SafeArea(
        child: BlocBuilder<TripBloc, TripState>(
          builder: (context, state) {
            if (state is TripLoading || state is TripInitial) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is TripError) {
              return Center(child: Text('Error: ${state.message}'));
            } else if (state is TripEmpty) {
              return const Center(child: Text('No trips found.'));
            } else if (state is TripLoaded) {
              final trips = state.trips;
              return ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: trips.length,
                separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
                itemBuilder: (context, index) {
                  final trip = trips[index];
                  final duration = _calculateDuration(trip);
                  final date = DateTime.tryParse(trip.createdAt) ?? DateTime.now();
                  final isToday = DateTime.now().difference(date).inDays == 0;
                  final header = isToday ? 'Today' : 'Earlier';
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (index == 0 || _differentDay(trips[index - 1], trip))
                        Padding(
                          padding: EdgeInsets.only(bottom: AppSpacing.sm, top: index != 0 ? AppSpacing.xl : 0),
                          child: _buildDateHeader(header),
                        ),
                      _buildHistoryCard(
                        context, 
                        trip,
                        duration,
                      ),
                    ],
                  );
                },
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  bool _differentDay(Trip a, Trip b) {
    final dateA = DateTime.tryParse(a.createdAt) ?? DateTime.now();
    final dateB = DateTime.tryParse(b.createdAt) ?? DateTime.now();
    return dateA.day != dateB.day || dateA.month != dateB.month || dateA.year != dateB.year;
  }

  Widget _buildDateHeader(String title) {
    return Text(
      title,
      style: AppTextStyles.titleLarge.copyWith(color: AppColors.primaryGreen),
    );
  }

  Widget _buildHistoryCard(
    BuildContext context, 
    Trip trip,
    String duration,
  ) {
    return AppCard(
      onTap: () {
        Navigator.of(context).pushNamed(AppRoutes.tripDetails, arguments: trip);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                trip.tripId,
                style: AppTextStyles.titleMedium,
              ),
              const Icon(Icons.chevron_right, color: AppColors.greyText),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildHistoryStat('Distance', '${trip.distance.toStringAsFixed(2)} km'),
              _buildHistoryStat('Duration', duration),
              _buildHistoryStat('Max Speed', '${trip.maxSpeed.toStringAsFixed(1)} km/h'),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(trip.status.toUpperCase(), style: AppTextStyles.labelLarge.copyWith(color: AppColors.freshGreen)),
        ],
      ),
    );
  }

  Widget _buildHistoryStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: AppTextStyles.bodyLarge),
        Text(label, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.greyText)),
      ],
    );
  }
}
