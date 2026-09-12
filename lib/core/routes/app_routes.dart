import 'package:flutter/material.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/permission/presentation/pages/permission_page.dart';
import '../../features/trip/presentation/pages/home_page.dart';
import '../../features/trip/presentation/pages/active_trip_page.dart';
import '../../features/trip/presentation/pages/end_trip_page.dart';
import '../../features/trip/presentation/pages/trip_summary_page.dart';
import '../../features/trip/presentation/pages/trip_history_page.dart';
import '../../features/trip/presentation/pages/trip_details_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/settings/presentation/pages/help_page.dart';

class AppRoutes {
  static const splash = '/splash';
  static const permission = '/permissions';
  static const home = '/home';
  static const activeTrip = '/active-trip';
  static const endTrip = '/end-trip';
  static const tripSummary = '/trip-summary';
  static const tripHistory = '/trip-history';
  static const tripDetails = '/trip-details';
  static const settings = '/settings';
  static const help = '/help';

  static Map<String, WidgetBuilder> get routes => {
        splash: (context) => const SplashPage(),
        permission: (context) => const PermissionPage(),
        home: (context) => const HomePage(),
        activeTrip: (context) => const ActiveTripPage(),
        endTrip: (context) => const EndTripPage(),
        tripSummary: (context) => const TripSummaryPage(),
        tripHistory: (context) => const TripHistoryPage(),
        tripDetails: (context) => const TripDetailsPage(),
        settings: (context) => const SettingsPage(),
        help: (context) => const HelpPage(),
      };
}
