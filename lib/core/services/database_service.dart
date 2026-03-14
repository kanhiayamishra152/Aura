// --- FILE: lib/core/services/database_service.dart ---
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/study_session_model.dart';
import '../models/leaderboard_entry_model.dart';

/// A singleton service to manage SQLite database operations.
/// Ensures offline-first capability for study sessions and leaderboard data.
class DatabaseService {
  DatabaseService._privateConstructor();
  static final DatabaseService _instance = DatabaseService._privateConstructor();
  factory DatabaseService() => _instance;

  static Database? _database;

  final String _tableNameSessions = 'study_sessions';
  final String _tableNameLeaderboard = 'leaderboard_entries';

  /// Getter for the database instance. Initializes if null.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initializes the database and creates tables if they don't exist.
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'focus_app_db.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Creates the necessary tables for the first time.
  Future<void> _onCreate(Database db, int version) async {
    // Table for storing focus/study session history
    await db.execute('''
      CREATE TABLE $_tableNameSessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        startTime INTEGER NOT NULL,
        endTime INTEGER NOT NULL,
        durationSeconds INTEGER NOT NULL,
        sessionType TEXT NOT NULL,
        isCompleted INTEGER NOT NULL,
        taskName TEXT,
        synced INTEGER DEFAULT 0
      )
    ''');

    // Table for storing local leaderboard entries before syncing
    await db.execute('''
      CREATE TABLE $_tableNameLeaderboard (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userName TEXT NOT NULL,
        score INTEGER NOT NULL,
        totalTimeFocused INTEGER NOT NULL,
        rank INTEGER,
        lastUpdated INTEGER NOT NULL,
        synced INTEGER DEFAULT 0
      )
    ''');
  }

  /// Handles database migrations for future versions.
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Migration logic will go here as the schema evolves
    if (oldVersion < 2) {
      // Example: await db.execute("ALTER TABLE $_tableNameSessions ADD COLUMN notes TEXT;");
    }
  }

  // =============================================================
  // STUDY SESSION CRUD OPERATIONS
  // =============================================================

  /// Inserts a new study session into the database.
  Future<int> insertStudySession(StudySessionModel session) async {
    final db = await database;
    return await db.insert(
      _tableNameSessions,
      session.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Retrieves all study sessions, ordered by most recent first.
  Future<List<StudySessionModel>> getAllStudySessions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableNameSessions,
      orderBy: 'startTime DESC',
    );
    return List.generate(maps.length, (i) {
      return StudySessionModel.fromMap(maps[i]);
    });
  }

  /// Retrieves sessions within a specific date range (for analytics).
  Future<List<StudySessionModel>> getSessionsInRange(int startTimestamp, int endTimestamp) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableNameSessions,
      where: 'startTime >= ? AND startTime <= ?',
      whereArgs: [startTimestamp, endTimestamp],
      orderBy: 'startTime DESC',
    );
    return List.generate(maps.length, (i) {
      return StudySessionModel.fromMap(maps[i]);
    });
  }

  /// Calculates the total focus time in seconds for a specific period.
  Future<int> getTotalFocusTime(int startTimestamp, int endTimestamp) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT SUM(durationSeconds) as total 
      FROM $_tableNameSessions 
      WHERE startTime >= ? AND startTime <= ? AND isCompleted = 1
    ''', [startTimestamp, endTimestamp]);
    
    return result.isNotEmpty ? (result.first['total'] as int? ?? 0) : 0;
  }

  /// Deletes old sessions older than a specific timestamp (cleanup).
  Future<int> deleteOldSessions(int timestampThreshold) async {
    final db = await database;
    return await db.delete(
      _tableNameSessions,
      where: 'endTime < ?',
      whereArgs: [timestampThreshold],
    );
  }

  // =============================================================
  // LEADERBOARD CRUD OPERATIONS
  // =============================================================

  /// Inserts or updates the local user's leaderboard entry.
  Future<void> upsertLocalLeaderboardEntry(LeaderboardEntryModel entry) async {
    final db = await database;
    // Check if entry exists (assuming one local user profile for now, ID 1)
    // In a real multi-user scenario, you'd check by userId.
    // Here we simply replace the first row or insert.
    final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM $_tableNameLeaderboard'));
    
    if (count == 0) {
      await db.insert(_tableNameLeaderboard, entry.toMap());
    } else {
      await db.update(
        _tableNameLeaderboard,
        entry.toMap(),
        where: 'id = ?',
        whereArgs: [entry.id ?? 1],
      );
    }
  }

  /// Gets the local user's current stats.
  Future<LeaderboardEntryModel?> getLocalLeaderboardEntry() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableNameLeaderboard,
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return LeaderboardEntryModel.fromMap(maps.first);
    }
    return null;
  }

  /// Clears the local leaderboard (e.g., on user logout).
  Future<int> clearLeaderboard() async {
    final db = await database;
    return await db.delete(_tableNameLeaderboard);
  }

  // =============================================================
  // SYNC HELPER METHODS
  // =============================================================

  /// Fetches unsynced sessions to push to the server when internet is restored.
  Future<List<StudySessionModel>> getUnsyncedSessions() async {
    final db = await database;
    final maps = await db.query(
      _tableNameSessions,
      where: 'synced = ?',
      whereArgs: [0],
    );
    return maps.map((map) => StudySessionModel.fromMap(map)).toList();
  }

  /// Marks a session as synced after successful server upload.
  Future<void> markSessionAsSynced(int id) async {
    final db = await database;
    await db.update(
      _tableNameSessions,
      {'synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
