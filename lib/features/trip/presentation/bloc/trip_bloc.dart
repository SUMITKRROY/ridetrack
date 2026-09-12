import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/create_trip.dart';
import '../../domain/usecases/update_trip.dart';
import '../../domain/usecases/get_trip_details.dart';
import '../../domain/usecases/get_trips.dart';
import '../../domain/usecases/seed_dummy_trips.dart';
import 'trip_event.dart';
import 'trip_state.dart';

class TripBloc extends Bloc<TripEvent, TripState> {
  final GetTrips getTrips;
  final CreateTrip createTrip;
  final UpdateTrip updateTrip;
  final GetTripDetails getTripDetails;
  final SeedDummyTrips seedDummyTrips;

  TripBloc({
    required this.getTrips,
    required this.createTrip,
    required this.updateTrip,
    required this.getTripDetails,
    required this.seedDummyTrips,
  }) : super(TripInitial()) {
    on<LoadTrips>(_onLoadTrips);
    on<RefreshTrips>(_onRefreshTrips);
    on<CreateTripEvent>(_onCreateTrip);
    on<UpdateTripEvent>(_onUpdateTrip);
    on<LoadTripDetails>(_onLoadTripDetails);
    on<SeedDummyTripsEvent>(_onSeedDummyTrips);
  }

  Future<void> _onLoadTrips(LoadTrips event, Emitter<TripState> emit) async {
    emit(TripLoading());
    try {
      final trips = await getTrips();
      if (trips.isEmpty) {
        emit(TripEmpty());
      } else {
        emit(TripLoaded(trips));
      }
    } catch (e) {
      emit(TripError(e.toString()));
    }
  }

  Future<void> _onRefreshTrips(RefreshTrips event, Emitter<TripState> emit) async {
    try {
      final trips = await getTrips();
      if (trips.isEmpty) {
        emit(TripEmpty());
      } else {
        emit(TripLoaded(trips));
      }
    } catch (e) {
      emit(TripError(e.toString()));
    }
  }

  Future<void> _onCreateTrip(CreateTripEvent event, Emitter<TripState> emit) async {
    try {
      await createTrip(event.trip);
      final trips = await getTrips();
      if (trips.isEmpty) {
        emit(TripEmpty());
      } else {
        emit(TripLoaded(trips));
      }
    } catch (e) {
      emit(TripError(e.toString()));
    }
  }

  Future<void> _onUpdateTrip(UpdateTripEvent event, Emitter<TripState> emit) async {
    try {
      await updateTrip(event.trip);
      final trips = await getTrips();
      if (trips.isEmpty) {
        emit(TripEmpty());
      } else {
        emit(TripLoaded(trips));
      }
    } catch (e) {
      emit(TripError(e.toString()));
    }
  }

  Future<void> _onLoadTripDetails(LoadTripDetails event, Emitter<TripState> emit) async {
    emit(TripLoading());
    try {
      final trip = await getTripDetails(event.tripId);
      if (trip != null) {
        emit(TripDetailsLoaded(trip));
      } else {
        emit(const TripError("Trip not found"));
      }
    } catch (e) {
      emit(TripError(e.toString()));
    }
  }

  Future<void> _onSeedDummyTrips(SeedDummyTripsEvent event, Emitter<TripState> emit) async {
    try {
      await seedDummyTrips();
      add(RefreshTrips());
    } catch (e) {
      emit(TripError(e.toString()));
    }
  }
}
