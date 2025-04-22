import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/director.dart';
import '../models/movie.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), 'movie_tracker.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE directors (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            bio TEXT,
            photo TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE movies (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            genre TEXT,
            rating REAL,
            poster TEXT,
            synopsis TEXT,
            director_id INTEGER,
            FOREIGN KEY(director_id) REFERENCES directors(id)
          )
        ''');
      },
    );
  }

  // Director methods
  Future<int> insertDirector(Director director) async {
    final dbClient = await db;
    return await dbClient.insert('directors', director.toMap());
  }

  Future<List<Director>> getAllDirectors() async {
    final dbClient = await db;
    final maps = await dbClient.query('directors');
    return maps.map((m) => Director.fromMap(m)).toList();
  }

  Future<String?> fetchDirectorName(int id) async {
    final director = await getDirectorById(id);
    return director?.name ?? "Unknown Director";
  }

  Future<Director?> getDirectorById(int id) async {
    final dbClient = await db;
    final maps = await dbClient.query(
      'directors',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Director.fromMap(maps.first);
    }
    return null;
  }

  Future<int> deleteDirector(int id) async {
    final dbClient = await db;
    return await dbClient.delete('directors', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateDirector(Director director) async {
    final dbClient = await db;
    await dbClient.update(
      'directors',
      director.toMap(),
      where: 'id = ?',
      whereArgs: [director.id],
    );
  }

  // Movie methods
  Future<int> insertMovie(Movie movie) async {
    final dbClient = await db;
    return await dbClient.insert('movies', movie.toMap());
  }

  Future<List<Movie>> getAllMovies() async {
    final dbClient = await db;
    final maps = await dbClient.query('movies');
    return maps.map((m) => Movie.fromMap(m)).toList();
  }

  Future<void> updateMovie(Movie movie) async {
    final dbClient = await db;
    await dbClient.update(
      'movies',
      movie.toMap(),
      where: 'id = ?',
      whereArgs: [movie.id],
    );
  }

  Future<int> deleteMovie(int id) async {
    final dbClient = await db;
    return await dbClient.delete('movies', where: 'id = ?', whereArgs: [id]);
  }

  // Filter movie by genre or rating (opsional)
  Future<List<Movie>> filterMovies({String? genre, double? minRating}) async {
    final dbClient = await db;
    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (genre != null) {
      whereClause += 'genre = ?';
      whereArgs.add(genre);
    }

    if (minRating != null) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'rating >= ?';
      whereArgs.add(minRating);
    }

    final maps = await dbClient.query(
      'movies',
      where: whereClause.isNotEmpty ? whereClause : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
    );

    return maps.map((m) => Movie.fromMap(m)).toList();
  }
}
