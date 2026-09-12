import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/stat_card.dart';
import '../../domain/entities/trip.dart';
import '../bloc/trip_bloc.dart';
import '../bloc/trip_event.dart';
import '../bloc/trip_state.dart';
import '../bloc/location_bloc.dart';
import '../bloc/location_event.dart';
import '../bloc/location_state.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    final tripBloc = context.read<TripBloc>();
    tripBloc.add(SeedDummyTripsEvent());
    tripBloc.add(LoadTrips());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final tripState = context.read<TripBloc>().state;
      if (tripState is TripLoaded) {
        _checkAndResumeOngoingTrip(tripState.trips);
      }
    });
  }

  void _checkAndResumeOngoingTrip(List<Trip> trips) {
    final locBloc = context.read<LocationBloc>();
    final locState = locBloc.state;
    if (locState is LocationTracking && locState.isTracking) return;
    if (locState is LocationLoading) return;

    Trip? ongoingTrip;
    for (final t in trips) {
      if (t.status.toLowerCase() == 'ongoing') {
        ongoingTrip = t;
        break;
      }
    }

    if (ongoingTrip != null) {
      final startDt = DateTime.tryParse(ongoingTrip.startTime) ?? DateTime.now();
      locBloc.add(StartLocationTracking(
        tripId: ongoingTrip.tripId,
        startTime: startDt,
        initialDistance: ongoingTrip.distance,
        initialMaxSpeed: ongoingTrip.maxSpeed,
      ));
    }
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours.toString().padLeft(2, '0');
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  String _resolveActiveTripId(List<Trip> trips, LocationState locState) {
    if (locState is LocationTracking && locState.isTracking) {
      if (locState.tripId != null && locState.tripId!.isNotEmpty) {
        return locState.tripId!;
      }
    }
    for (final trip in trips) {
      if (trip.status.toLowerCase() == 'ongoing') {
        return trip.tripId;
      }
    }
    return '';
  }

  String _calculateStaticDuration(Trip trip) {
    if (trip.endTime != null && trip.endTime!.isNotEmpty) {
      try {
        final s = DateTime.parse(trip.startTime);
        final e = DateTime.parse(trip.endTime!);
        final diff = e.difference(s);
        if (!diff.isNegative) {
          return _formatDuration(diff);
        }
      } catch (_) {}
    }

    if (trip.updatedAt.isNotEmpty && trip.updatedAt != trip.startTime) {
      try {
        final s = DateTime.parse(trip.startTime);
        final u = DateTime.parse(trip.updatedAt);
        final diff = u.difference(s);
        if (!diff.isNegative && diff.inSeconds > 0) {
          return _formatDuration(diff);
        }
      } catch (_) {}
    }

    if (trip.distance > 0) {
      final approxSpeedKmh = trip.maxSpeed > 0 ? (trip.maxSpeed * 0.55).clamp(20.0, 60.0) : 35.0;
      final approxSeconds = ((trip.distance / approxSpeedKmh) * 3600).round();
      return _formatDuration(Duration(seconds: approxSeconds));
    }

    return '00:00:00';
  }

  String _formatDateTime(String createdAt) {
    final dt = DateTime.tryParse(createdAt)?.toLocal() ?? DateTime.now();
    final now = DateTime.now();
    final isToday = dt.year == now.year && dt.month == now.month && dt.day == now.day;
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    final timeStr = '$hour:$minute $period';
    return isToday ? 'Today, $timeStr' : '${dt.day}/${dt.month}/${dt.year}, $timeStr';
  }

  void _endTripFromHome(BuildContext context, LocationState locState, Trip? ongoingTrip) {
    Trip tripToEnd;
    if (locState is LocationTracking) {
      tripToEnd = Trip(
        tripId: locState.tripId ?? (ongoingTrip?.tripId ?? 'TRIP-ACTIVE'),
        status: 'ongoing',
        startTime: locState.startTime?.toIso8601String() ?? (ongoingTrip?.startTime ?? DateTime.now().toIso8601String()),
        distance: double.parse(locState.distance.toStringAsFixed(2)),
        currentSpeed: double.parse((locState.location.speed * 3.6).toStringAsFixed(1)),
        maxSpeed: double.parse(locState.maxSpeed.toStringAsFixed(1)),
        latitude: locState.location.latitude,
        longitude: locState.location.longitude,
        accuracy: locState.location.accuracy,
        createdAt: ongoingTrip?.createdAt ?? (locState.startTime?.toIso8601String() ?? DateTime.now().toIso8601String()),
        updatedAt: DateTime.now().toIso8601String(),
      );
    } else if (ongoingTrip != null) {
      tripToEnd = ongoingTrip;
    } else {
      return;
    }
    Navigator.of(context).pushNamed(AppRoutes.endTrip, arguments: tripToEnd);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TripBloc, TripState>(
      listener: (context, tripState) {
        if (tripState is TripLoaded) {
          _checkAndResumeOngoingTrip(tripState.trips);
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: BlocBuilder<LocationBloc, LocationState>(
            builder: (context, locState) {
              final tripState = context.watch<TripBloc>().state;
              Trip? ongoingTrip;
              if (tripState is TripLoaded) {
                for (final t in tripState.trips) {
                  if (t.status.toLowerCase() == 'ongoing') {
                    ongoingTrip = t;
                    break;
                  }
                }
              }

              final isTripActive = (locState is LocationTracking && locState.isTracking) || ongoingTrip != null;

              return Stack(
                children: [
                  IndexedStack(
                    index: _currentIndex,
                    children: [
                      _buildHomeTab(context, locState),
                      _buildTripsTab(context, locState),
                      const Center(child: Text("Settings Tab Placeholder. Use Settings.")),
                    ],
                  ),
                  if (isTripActive && _currentIndex != 0 && locState is LocationTracking && locState.isTracking)
                    Positioned(
                      left: AppSpacing.md,
                      right: AppSpacing.md,
                      bottom: AppSpacing.md,
                      child: _buildFloatingActiveTripBar(context, locState),
                    ),
                ],
              );
            },
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            if (index == 2) {
              Navigator.of(context).pushNamed(AppRoutes.settings);
            } else {
              setState(() {
                _currentIndex = index;
              });
            }
          },
          selectedItemColor: AppColors.primaryGreen,
          unselectedItemColor: AppColors.greyText,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Trips'),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeTab(BuildContext context, LocationState locState) {
    return BlocBuilder<TripBloc, TripState>(
      builder: (context, state) {
        List<Trip> trips = [];
        if (state is TripLoaded) {
          trips = state.trips;
        }

        Trip? ongoingTrip;
        for (final t in trips) {
          if (t.status.toLowerCase() == 'ongoing') {
            ongoingTrip = t;
            break;
          }
        }

        final isTripActive = (locState is LocationTracking && locState.isTracking) || ongoingTrip != null;

        final now = DateTime.now();
        final activeTripId = _resolveActiveTripId(trips, locState);

        final overviewTrips = trips.where((t) {
          // Include dummy rides in the overview as requested
          if (t.tripId.startsWith('TRIP-100')) return true;
          final d = DateTime.tryParse(t.createdAt)?.toLocal();
          if (d == null) return false;
          return d.year == now.year && d.month == now.month && d.day == now.day;
        }).toList();

        final todayCount = overviewTrips.length.toString().padLeft(2, '0');
        final todayDistance = overviewTrips.fold(0.0, (sum, t) {
          final isThisActive = activeTripId.isNotEmpty && t.tripId == activeTripId;
          final dist = isThisActive && locState is LocationTracking && locState.distance > 0
              ? locState.distance
              : t.distance;
          return sum + dist;
        });
        final distanceStr = '${todayDistance.toStringAsFixed(1)} km';

        return RefreshIndicator(
          onRefresh: () async {
            context.read<TripBloc>().add(RefreshTrips());
          },
          color: AppColors.primaryGreen,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Good Morning 👋', style: AppTextStyles.bodyLarge.copyWith(color: AppColors.greyText)),
                        const Text('KSKT Rider', style: AppTextStyles.displayMedium),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined, size: 28),
                      onPressed: () {},
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                if (isTripActive)
                  _buildActiveTripBanner(context, locState, ongoingTrip)
                else
                  _buildReadyToRideBanner(context),
                        const SizedBox(height: AppSpacing.xl),
                        const Text('Today\'s Overview', style: AppTextStyles.titleLarge),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          children: [
                            Expanded(
                              child: StatCard(title: 'Trips', value: todayCount, icon: Icons.local_shipping_outlined),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: StatCard(title: 'Distance', value: distanceStr, icon: Icons.route_outlined),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Recent Trips', style: AppTextStyles.titleLarge),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _currentIndex = 1;
                                });
                              },
                              child: Text('See All', style: AppTextStyles.labelLarge.copyWith(color: AppColors.primaryGreen)),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        if (trips.isEmpty)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(AppSpacing.lg),
                              child: Text(
                                'No trips recorded yet. Tap START TRIP to begin!',
                                style: AppTextStyles.bodyMedium,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        else
                          ...trips.take(5).map((trip) => Padding(
                                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                                child: _buildRecentTripCard(context, trip, locState, activeTripId),
                              )),
                      ],
                    ),
                  ),
                );
              },
            );
          }

  Widget _buildTripsTab(BuildContext context, LocationState locState) {
    return BlocBuilder<TripBloc, TripState>(
      builder: (context, state) {
        List<Trip> trips = [];
        if (state is TripLoaded) {
          trips = state.trips;
        }

        final activeTripId = _resolveActiveTripId(trips, locState);

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('All Trips', style: AppTextStyles.displayMedium),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: AppColors.primaryGreen),
                    onPressed: () => context.read<TripBloc>().add(RefreshTrips()),
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  context.read<TripBloc>().add(RefreshTrips());
                },
                color: AppColors.primaryGreen,
                child: trips.isEmpty
                    ? const Center(
                        child: Text(
                          'No trips recorded yet.\nStart a trip from the Home tab!',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyLarge,
                        ),
                      )
                    : ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        itemCount: trips.length,
                        separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
                        itemBuilder: (context, index) {
                          return _buildRecentTripCard(context, trips[index], locState, activeTripId);
                        },
                      ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRecentTripCard(
    BuildContext context,
    Trip trip,
    LocationState locState,
    String activeTripId,
  ) {
    final isThisTripActive = activeTripId.isNotEmpty && trip.tripId == activeTripId;

    final duration = isThisTripActive && locState is LocationTracking
        ? _formatDuration(locState.duration)
        : (isThisTripActive
            ? _formatDuration(DateTime.now().difference(DateTime.tryParse(trip.startTime) ?? DateTime.now()))
            : _calculateStaticDuration(trip));

    final distanceStr = isThisTripActive && locState is LocationTracking && locState.distance > 0
        ? '${locState.distance.toStringAsFixed(1)} km'
        : '${trip.distance.toStringAsFixed(1)} km';

    final formattedDate = _formatDateTime(trip.createdAt);

    return AppCard(
      onTap: () {
        if (isThisTripActive) {
          Navigator.of(context).pushNamed(AppRoutes.activeTrip);
        } else {
          Navigator.of(context).pushNamed(AppRoutes.tripDetails, arguments: trip);
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(trip.tripId, style: AppTextStyles.titleMedium),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isThisTripActive
                      ? AppColors.primaryGreen.withOpacity(0.12)
                      : AppColors.lightGreen.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isThisTripActive) ...[
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppColors.freshGreen,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      (isThisTripActive ? 'ONGOING' : trip.status).toUpperCase(),
                      style: AppTextStyles.labelLarge.copyWith(
                        fontSize: 12,
                        color: isThisTripActive ? AppColors.primaryGreen : AppColors.greyText,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(distanceStr, style: AppTextStyles.bodyLarge),
              Text(
                duration,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: isThisTripActive ? FontWeight.bold : FontWeight.normal,
                  color: isThisTripActive ? AppColors.primaryGreen : null,
                ),
              ),
              Text(
                isThisTripActive && locState is LocationTracking && locState.location.speed > 0
                    ? '${(locState.location.speed * 3.6).toStringAsFixed(1)} km/h'
                    : '${trip.maxSpeed.toStringAsFixed(1)} km/h max',
                style: AppTextStyles.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(formattedDate, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.greyText)),
        ],
      ),
    );
  }

  Widget _buildReadyToRideBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        image: DecorationImage(
          image: const AssetImage('assets/images/farm_pattern.jpg'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            AppColors.primaryGreen.withOpacity(0.9),
            BlendMode.srcOver,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'READY TO RIDE?',
            style: AppTextStyles.titleLarge.copyWith(color: AppColors.white),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Start a new trip and let KSKT\ntrack your journey.',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.lightGreen),
          ),
          const SizedBox(height: AppSpacing.lg),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushNamed(AppRoutes.activeTrip).then((_) {
                if (context.mounted) {
                  context.read<TripBloc>().add(RefreshTrips());
                }
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.golden,
              foregroundColor: AppColors.darkText,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
            ),
            child: const Text('START TRIP', style: AppTextStyles.labelLarge),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveTripBanner(BuildContext context, LocationState locState, Trip? ongoingTrip) {
    final isLocTracking = locState is LocationTracking && locState.isTracking;
    final speedKmH = isLocTracking ? (locState.location.speed * 3.6).toStringAsFixed(1) : '0.0';
    final durationStr = isLocTracking
        ? _formatDuration(locState.duration)
        : (ongoingTrip != null
            ? _formatDuration(DateTime.now().difference(DateTime.tryParse(ongoingTrip.startTime) ?? DateTime.now()))
            : '00:00:00');
    final distanceVal = isLocTracking ? locState.distance : (ongoingTrip?.distance ?? 0.0);
    final distanceStr = '${distanceVal.toStringAsFixed(2)} km';
    final activeTripId = (isLocTracking ? locState.tripId : null) ?? ongoingTrip?.tripId ?? '';

    return InkWell(
      onTap: () {
        Navigator.of(context).pushNamed(AppRoutes.activeTrip);
      },
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.primaryGreen,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryGreen.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: AppColors.freshGreen,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Flexible(
                        child: Text(
                          'TRIP ACTIVE: $activeTripId',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: const Text(
                    'FULLSCREEN',
                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildBannerMetric('Speed', '$speedKmH km/h'),
                _buildBannerMetric('Distance', distanceStr),
                _buildBannerMetric('Duration', durationStr),
              ],
            ),
            if (isLocTracking && locState.address != null && locState.address!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  const Icon(Icons.location_on, color: AppColors.lightGreen, size: 15),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      locState.address!,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.open_in_full_rounded, size: 18),
                    label: const Text('FULL SCREEN'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.white,
                      foregroundColor: AppColors.primaryGreen,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      textStyle: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      Navigator.of(context).pushNamed(AppRoutes.activeTrip).then((_) {
                        if (context.mounted) {
                          context.read<TripBloc>().add(RefreshTrips());
                        }
                      });
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.stop_circle, size: 18),
                    label: const Text('END TRIP'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: AppColors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      textStyle: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      _endTripFromHome(context, locState, ongoingTrip);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActiveTripBar(BuildContext context, LocationTracking state) {
    final speedKmH = (state.location.speed * 3.6).toStringAsFixed(1);
    final distanceStr = '${state.distance.toStringAsFixed(2)} km';
    final durationStr = _formatDuration(state.duration);

    return Material(
      elevation: 6,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      color: AppColors.darkGreen,
      child: InkWell(
        onTap: () {
          Navigator.of(context).pushNamed(AppRoutes.activeTrip);
        },
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: AppColors.freshGreen,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Trip Active: ${state.tripId ?? ''}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '$distanceStr • $speedKmH km/h • $durationStr',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 11),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  minimumSize: const Size(54, 32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                ),
                onPressed: () {
                  _endTripFromHome(context, state, null);
                },
                child: const Text('END', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBannerMetric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: AppColors.lightGreen.withOpacity(0.9), fontSize: 11),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
