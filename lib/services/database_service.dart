import 'package:hotel/core/app_constants.dart';
import 'package:hotel/data/hotel_model.dart';
import 'package:hotel/data/sensor_model.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  DatabaseService._();
  static final DatabaseService instance = DatabaseService._();

  Database? _database;

  Future<Database> get db async {
    _database ??= await _open();
    return _database!;
  }

  Future<Database> _open() async {
    final dbPath = p.join(await getDatabasesPath(), 'hotel_app.db');
    return openDatabase(
      dbPath,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database database, int version) async {
    await database.execute('''
      CREATE TABLE hotels (
        id TEXT PRIMARY KEY,
        nombre TEXT NOT NULL,
        location TEXT NOT NULL,
        descripcion TEXT NOT NULL,
        precio REAL NOT NULL,
        rating REAL NOT NULL,
        fotos TEXT NOT NULL DEFAULT '[]',
        servicios TEXT NOT NULL DEFAULT '[]'
      )
    ''');

    await database.execute('''
      CREATE TABLE sensor_readings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type INTEGER NOT NULL,
        x REAL NOT NULL,
        y REAL NOT NULL,
        z REAL NOT NULL,
        hotel_id TEXT,
        nota TEXT NOT NULL DEFAULT '',
        timestamp TEXT NOT NULL
      )
    ''');

    for (final room in AppData.defaultRooms) {
      await database.insert('hotels', room.toMap());
    }
  }

  Future<List<HotelRoom>> fetchHotels() async {
    final rows = await (await db).query('hotels', orderBy: 'rowid ASC');
    return rows.map(HotelRoom.fromMap).toList();
  }

  Future<void> insertHotel(HotelRoom room) async {
    await (await db).insert(
      'hotels',
      room.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateHotel(HotelRoom room) async {
    await (await db).update(
      'hotels',
      room.toMap(),
      where: 'id = ?',
      whereArgs: [room.id],
    );
  }

  Future<void> deleteHotel(String id) async {
    await (await db).delete('hotels', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<SensorReading>> fetchReadings({
    SensorType? type,
    String? hotelId,
    int limit = 200,
  }) async {
    final whereClauses = <String>[];
    final whereArgs = <Object?>[];

    if (type != null) {
      whereClauses.add('type = ?');
      whereArgs.add(type.index);
    }
    if (hotelId != null) {
      whereClauses.add('hotel_id = ?');
      whereArgs.add(hotelId);
    }

    final rows = await (await db).query(
      'sensor_readings',
      where: whereClauses.isNotEmpty ? whereClauses.join(' AND ') : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'timestamp DESC',
      limit: limit,
    );

    return rows.map(SensorReading.fromMap).toList();
  }

  Future<int> insertReading(SensorReading reading) async {
    return (await db).insert('sensor_readings', reading.toMap());
  }

  Future<void> deleteReading(int id) async {
    await (await db).delete('sensor_readings', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteAllReadings({SensorType? type}) async {
    if (type != null) {
      await (await db).delete('sensor_readings', where: 'type = ?', whereArgs: [type.index]);
    } else {
      await (await db).delete('sensor_readings');
    }
  }

  Future<Map<String, int>> readingStats() async {
    final rows = await (await db).rawQuery(
      'SELECT type, COUNT(*) as cnt FROM sensor_readings GROUP BY type',
    );
    final map = <String, int>{};
    for (final row in rows) {
      final type = SensorType.values[row['type'] as int];
      map[type.label] = row['cnt'] as int;
    }
    return map;
  }
}
