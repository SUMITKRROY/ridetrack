import 'package:get_it/get_it.dart';
import '../../core/database/database_helper.dart';
import '../../core/services/location/location_service.dart';
import '../../core/services/location/location_service_impl.dart';
import '../../core/services/geocoding/geocoding_service.dart';
import '../../core/services/geocoding/geocoding_service_impl.dart';

import '../../features/trip/data/datasources/trip_local_datasource.dart';
import '../../features/trip/data/repositories/trip_repository_impl.dart';
import '../../features/trip/domain/repositories/trip_repository.dart';
import '../../features/trip/domain/usecases/create_trip.dart';
import '../../features/trip/domain/usecases/update_trip.dart';
import '../../features/trip/domain/usecases/get_trip_details.dart';
import '../../features/trip/domain/usecases/get_trips.dart';
import '../../features/trip/domain/usecases/seed_dummy_trips.dart';
import '../../features/trip/presentation/bloc/trip_bloc.dart';

import '../../features/trip/data/repositories/location_repository_impl.dart';
import '../../features/trip/domain/repositories/location_repository.dart';
import '../../features/trip/domain/usecases/get_current_location.dart';
import '../../features/trip/domain/usecases/get_location_stream.dart';
import '../../features/trip/domain/usecases/get_address_from_location.dart';
import '../../features/trip/presentation/bloc/location_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // --- Core ---
  sl.registerLazySingleton<DatabaseHelper>(() => DatabaseHelper());
  sl.registerLazySingleton<LocationService>(() => LocationServiceImpl());
  sl.registerLazySingleton<GeocodingService>(() => GeocodingServiceImpl());

  // --- Data sources ---
  sl.registerLazySingleton<TripLocalDataSource>(
    () => TripLocalDataSourceImpl(databaseHelper: sl()),
  );

  // --- Repositories ---
  sl.registerLazySingleton<TripRepository>(
    () => TripRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton<LocationRepository>(
    () => LocationRepositoryImpl(
      locationService: sl(),
      geocodingService: sl(),
    ),
  );

  // --- Use cases ---
  sl.registerLazySingleton(() => GetTrips(repository: sl()));
  sl.registerLazySingleton(() => GetTripDetails(repository: sl()));
  sl.registerLazySingleton(() => CreateTrip(repository: sl()));
  sl.registerLazySingleton(() => UpdateTrip(repository: sl()));
  sl.registerLazySingleton(() => SeedDummyTrips(repository: sl()));
  
  sl.registerLazySingleton(() => GetCurrentLocation(repository: sl()));
  sl.registerLazySingleton(() => GetLocationStream(repository: sl()));
  sl.registerLazySingleton(() => GetAddressFromLocation(repository: sl()));

  // --- BLoC ---
  sl.registerFactory(
    () => TripBloc(
      getTrips: sl(),
      createTrip: sl(),
      updateTrip: sl(),
      getTripDetails: sl(),
      seedDummyTrips: sl(),
    ),
  );
  sl.registerFactory(
    () => LocationBloc(
      repository: sl(),
      getCurrentLocation: sl(),
      getLocationStream: sl(),
      getAddressFromLocation: sl(),
      tripLocalDataSource: sl(),
    ),
  );
}
