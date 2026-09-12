import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'tables/trip_table.dart';

class DatabaseHelper {
  static const String _databaseName = "kskt_rider.db";
  static const int _databaseVersion = 1;

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${TripTable.tableName} (
        ${TripTable.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${TripTable.tripId} TEXT NOT NULL UNIQUE,
        ${TripTable.status} TEXT NOT NULL,
        ${TripTable.startTime} TEXT NOT NULL,
        ${TripTable.endTime} TEXT,
        ${TripTable.distance} REAL NOT NULL DEFAULT 0,
        ${TripTable.currentSpeed} REAL NOT NULL DEFAULT 0,
        ${TripTable.maxSpeed} REAL NOT NULL DEFAULT 0,
        ${TripTable.latitude} REAL,
        ${TripTable.longitude} REAL,
        ${TripTable.accuracy} REAL,
        ${TripTable.createdAt} TEXT NOT NULL,
        ${TripTable.updatedAt} TEXT NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database migrations here for future versions
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
