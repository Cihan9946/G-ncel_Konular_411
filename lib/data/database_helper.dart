import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/discovered_fish.dart';

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final path = join(await getDatabasesPath(), 'derin_deniz.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE team_session (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            team_name TEXT NOT NULL,
            score INTEGER NOT NULL DEFAULT 0,
            created_at TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE discoveries (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            fish_id TEXT NOT NULL,
            station_id TEXT NOT NULL,
            discovered_at TEXT NOT NULL,
            discovered_by TEXT NOT NULL,
            session_id INTEGER,
            UNIQUE(fish_id, session_id)
          )
        ''');
        await db.execute('''
          CREATE TABLE completed_stations (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            station_id TEXT NOT NULL,
            session_id INTEGER NOT NULL,
            completed_at TEXT NOT NULL,
            UNIQUE(station_id, session_id)
          )
        ''');
      },
    );
  }

  Future<int> createSession(String teamName) async {
    final db = await database;
    return db.insert('team_session', {
      'team_name': teamName,
      'score': 0,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> addScore(int sessionId, int points) async {
    final db = await database;
    await db.rawUpdate(
      'UPDATE team_session SET score = score + ? WHERE id = ?',
      [points, sessionId],
    );
  }

  Future<int> getScore(int sessionId) async {
    final db = await database;
    final rows = await db.query(
      'team_session',
      columns: ['score'],
      where: 'id = ?',
      whereArgs: [sessionId],
    );
    if (rows.isEmpty) return 0;
    return rows.first['score'] as int? ?? 0;
  }

  Future<bool> saveDiscovery(int sessionId, DiscoveredFish d) async {
    final db = await database;
    try {
      await db.insert('discoveries', {
        ...d.toMap(),
        'session_id': sessionId,
      });
      return true;
    } on DatabaseException {
      return false;
    }
  }

  Future<List<DiscoveredFish>> getDiscoveries(int sessionId) async {
    final db = await database;
    final rows = await db.query(
      'discoveries',
      where: 'session_id = ?',
      whereArgs: [sessionId],
      orderBy: 'discovered_at DESC',
    );
    return rows.map((r) => DiscoveredFish.fromMap(r)).toList();
  }

  Future<bool> markStationComplete(int sessionId, String stationId) async {
    final db = await database;
    try {
      await db.insert('completed_stations', {
        'station_id': stationId,
        'session_id': sessionId,
        'completed_at': DateTime.now().toIso8601String(),
      });
      return true;
    } on DatabaseException {
      return false;
    }
  }

  Future<List<String>> completedStationIds(int sessionId) async {
    final db = await database;
    final rows = await db.query(
      'completed_stations',
      columns: ['station_id'],
      where: 'session_id = ?',
      whereArgs: [sessionId],
    );
    return rows.map((r) => r['station_id'] as String).toList();
  }
}
