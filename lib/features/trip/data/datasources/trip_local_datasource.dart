import '../models/trip_model.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/database/tables/trip_table.dart';
import 'package:sqflite/sqflite.dart';

abstract class TripLocalDataSource {
  Future<List<TripModel>> getTrips();
  Future<TripModel?> getTripById(String tripId);
  Future<int> insertTrip(TripModel trip);
  Future<int> updateTrip(TripModel trip);
  Future<void> insertDummyData();
  Future<void> deleteAllTrips();
}

class TripLocalDataSourceImpl implements TripLocalDataSource {
  final DatabaseHelper databaseHelper;

  TripLocalDataSourceImpl({required this.databaseHelper});

  @override
  Future<List<TripModel>> getTrips() async {
    final db = await databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      TripTable.tableName,
      orderBy: '${TripTable.updatedAt} DESC, ${TripTable.id} DESC',
    );
    return maps.map((map) => TripModel.fromMap(map)).toList();
  }

  @override
  Future<TripModel?> getTripById(String tripId) async {
    final db = await databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      TripTable.tableName,
      where: '${TripTable.tripId} = ?',
      whereArgs: [tripId],
    );
    if (maps.isNotEmpty) {
      return TripModel.fromMap(maps.first);
    }
    return null;
  }

  @override
  Future<int> insertTrip(TripModel trip) async {
    final db = await databaseHelper.database;
    return await db.insert(
      TripTable.tableName,
      trip.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<int> updateTrip(TripModel trip) async {
    final db = await databaseHelper.database;
    final rowsAffected = await db.update(
      TripTable.tableName,
      trip.toMap(),
      where: '${TripTable.tripId} = ?',
      whereArgs: [trip.tripId],
    );
    if (rowsAffected == 0) {
      return await db.insert(
        TripTable.tableName,
        trip.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    return rowsAffected;
  }

  @override
  Future<void> deleteAllTrips() async {
    final db = await databaseHelper.database;
    await db.delete(TripTable.tableName);
  }

  @override
  Future<void> insertDummyData() async {
    final db = await databaseHelper.database;
    
    // Check if table is empty
    final countResult = await db.rawQuery('SELECT COUNT(*) FROM ${TripTable.tableName}');
    final int count = Sqflite.firstIntValue(countResult) ?? 0;
    
    if (count == 0) {
      final now = DateTime.now();
      final t1Start = now.subtract(const Duration(hours: 4, minutes: 25));
      final t1End = now.subtract(const Duration(hours: 3, minutes: 50));
      final t2Start = now.subtract(const Duration(hours: 2, minutes: 40));
      final t2End = now.subtract(const Duration(hours: 1, minutes: 55));
      final t3Start = now.subtract(const Duration(hours: 1, minutes: 10));
      final t3End = now.subtract(const Duration(minutes: 35));

      final dummyTrips = [
        TripModel(
          tripId: 'TRIP-1001',
          status: 'completed',
          startTime: t1Start.toIso8601String(),
          endTime: t1End.toIso8601String(),
          distance: 23.42,
          currentSpeed: 0,
          maxSpeed: 78.4,
          latitude: 28.6139,
          longitude: 77.2090,
          accuracy: 8.2,
          createdAt: t1Start.toIso8601String(),
          updatedAt: t1End.toIso8601String(),
        ),
        TripModel(
          tripId: 'TRIP-1002',
          status: 'completed',
          startTime: t2Start.toIso8601String(),
          endTime: t2End.toIso8601String(),
          distance: 31.20,
          currentSpeed: 0,
          maxSpeed: 72.0,
          createdAt: t2Start.toIso8601String(),
          updatedAt: t2End.toIso8601String(),
        ),
        TripModel(
          tripId: 'TRIP-1003',
          status: 'completed',
          startTime: t3Start.toIso8601String(),
          endTime: t3End.toIso8601String(),
          distance: 18.75,
          currentSpeed: 0,
          maxSpeed: 65.5,
          createdAt: t3Start.toIso8601String(),
          updatedAt: t3End.toIso8601String(),
        ),
      ];

      for (var trip in dummyTrips) {
        await insertTrip(trip);
      }
    }
  }
}
