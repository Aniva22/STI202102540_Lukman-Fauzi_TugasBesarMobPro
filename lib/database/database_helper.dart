import 'dart:async';
import 'package:flutter/foundation.dart'; // For ChangeNotifier
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/destination.dart';
import '../models/user.dart';

class DatabaseHelper extends ChangeNotifier {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  // Stream Controller for reactive updates
  final _destinationsController =
      StreamController<List<Destination>>.broadcast();
  Stream<List<Destination>> get destinationsStream =>
      _destinationsController.stream;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    // Initial fetch
    _refreshDestinations();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'travel_wisata.db');

    return await openDatabase(
      path,
      version: 6, // Increment version for Purwokerto Update
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE destinations(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        description TEXT,
        address TEXT,
        latitude REAL,
        longitude REAL,
        opening_time TEXT,
        closing_time TEXT,
        image_path TEXT,
        is_favorite INTEGER DEFAULT 0,
        created_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE,
        email TEXT UNIQUE,
        password TEXT,
        full_name TEXT,
        phone TEXT,
        avatar_path TEXT
      )
    ''');

    // Insert dummy data (Purwokerto based)
    await db.insert('destinations', {
      'name': 'Pancuran 7 Baturraden',
      'description':
          'Pemandian air panas belerang alami di kaki Gunung Slamet.',
      'address': 'Baturraden, Banyumas',
      'latitude': -7.3075,
      'longitude': 109.2272,
      'opening_time': '07:00',
      'closing_time': '17:00',
      'image_path': 'assets/images/upload/pancuran7.jpg',
      'is_favorite': 1,
      'created_at': DateTime.now().toIso8601String(),
    });

    await db.insert('destinations', {
      'name': 'Alun-alun Purwokerto',
      'description':
          'Pusat kota Purwokerto dengan suasana asri dan air mancur modern.',
      'address': 'Jl. Jend. Sudirman, Purwokerto',
      'latitude': -7.4245,
      'longitude': 109.2305,
      'opening_time': '00:00',
      'closing_time': '24:00',
      'image_path': 'assets/images/upload/alun_alun.jpg',
      'is_favorite': 0,
      'created_at': DateTime.now().toIso8601String(),
    });

    await db.insert('destinations', {
      'name': 'Menara Teratai',
      'description':
          'Ikon baru Purwokerto dengan pemandangan kota dari ketinggian.',
      'address': 'Jl. Bung Karno, Purwokerto',
      'latitude': -7.4290,
      'longitude': 109.2350,
      'opening_time': '09:00',
      'closing_time': '21:00',
      'image_path': 'assets/images/upload/menara_teratai.jpg',
      'is_favorite': 0,
      'created_at': DateTime.now().toIso8601String(),
    });

    // Default Developer Account
    await db.insert('users', {
      'username': 'admin',
      'email': 'admin@travel.com',
      'password': 'admin',
      'full_name': 'Lukman Fauzi',
      'phone': '081234567890',
      'avatar_path': '',
    });
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE users(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          username TEXT UNIQUE,
          email TEXT UNIQUE,
          password TEXT,
          full_name TEXT,
          phone TEXT,
          avatar_path TEXT
        )
      ''');
    }
    if (oldVersion < 3) {
      // Add is_favorite column if it doesn't exist
      await db.execute(
        'ALTER TABLE destinations ADD COLUMN is_favorite INTEGER DEFAULT 0',
      );
    }
    if (oldVersion < 4) {
      // Fallback for v4 (remote images) - handled by v5 override below if user jumps versions
    }
    if (oldVersion < 5) {
      // Migrate to Local Assets
      await db.update(
        'destinations',
        {'image_path': 'assets/images/upload/borobudur.jpg'},
        where: 'name LIKE ?',
        whereArgs: ['%Borobudur%'],
      );

      await db.update(
        'destinations',
        {'image_path': 'assets/images/upload/parangtritis.png'},
        where: 'name LIKE ?',
        whereArgs: ['%Parangtritis%'],
      );
    }
    if (oldVersion < 6) {
      // Migrate to Purwokerto Data
      // Clear old data first
      await db.delete('destinations');

      // Insert new data
      await db.insert('destinations', {
        'name': 'Pancuran 7 Baturraden',
        'description':
            'Pemandian air panas belerang alami di kaki Gunung Slamet.',
        'address': 'Baturraden, Banyumas',
        'latitude': -7.3075,
        'longitude': 109.2272,
        'opening_time': '07:00',
        'closing_time': '17:00',
        'image_path': 'assets/images/upload/pancuran7.jpg',
        'is_favorite': 1,
        'created_at': DateTime.now().toIso8601String(),
      });

      await db.insert('destinations', {
        'name': 'Alun-alun Purwokerto',
        'description':
            'Pusat kota Purwokerto dengan suasana asri dan air mancur modern.',
        'address': 'Jl. Jend. Sudirman, Purwokerto',
        'latitude': -7.4245,
        'longitude': 109.2305,
        'opening_time': '00:00',
        'closing_time': '24:00',
        'image_path': 'assets/images/upload/alun_alun.jpg',
        'is_favorite': 0,
        'created_at': DateTime.now().toIso8601String(),
      });

      await db.insert('destinations', {
        'name': 'Menara Teratai',
        'description':
            'Ikon baru Purwokerto dengan pemandangan kota dari ketinggian.',
        'address': 'Jl. Bung Karno, Purwokerto',
        'latitude': -7.4290,
        'longitude': 109.2350,
        'opening_time': '09:00',
        'closing_time': '21:00',
        'image_path': 'assets/images/upload/menara_teratai.jpg',
        'is_favorite': 0,
        'created_at': DateTime.now().toIso8601String(),
      });
    }
  }

  // Public method to trigger a refresh
  Future<void> loadDestinations() => _refreshDestinations();

  // Centralized Refresh Method
  Future<void> _refreshDestinations() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'destinations',
      orderBy: "id DESC",
    );
    final List<Destination> dests = List.generate(
      maps.length,
      (i) => Destination.fromMap(maps[i]),
    );
    if (!_destinationsController.isClosed) {
      _destinationsController.add(dests);
    }
  }

  // Destination CRUD Operations

  Future<int> insertDestination(Destination destination) async {
    final db = await database;
    final id = await db.insert(
      'destinations',
      destination.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await _refreshDestinations();
    return id;
  }

  Future<List<Destination>> getDestinations() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'destinations',
      orderBy: "id DESC",
    );
    return List.generate(maps.length, (i) => Destination.fromMap(maps[i]));
  }

  Future<List<Destination>> getFavoriteDestinations() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'destinations',
      where: 'is_favorite = ?',
      whereArgs: [1],
      orderBy: "id DESC",
    );
    return List.generate(maps.length, (i) => Destination.fromMap(maps[i]));
  }

  Future<Map<String, int>> getStats() async {
    final db = await database;
    final destCount =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM destinations'),
        ) ??
        0;
    final favCount =
        Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM destinations WHERE is_favorite = 1',
          ),
        ) ??
        0;
    return {'total': destCount, 'favorites': favCount};
  }

  Future<void> toggleFavorite(int id, bool isFavorite) async {
    final db = await database;
    await db.update(
      'destinations',
      {'is_favorite': isFavorite ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
    await _refreshDestinations();
  }

  Future<List<Destination>> searchDestinations(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'destinations',
      where: 'name LIKE ? OR description LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: "id DESC",
    );
    return List.generate(maps.length, (i) => Destination.fromMap(maps[i]));
  }

  Future<int> updateDestination(Destination destination) async {
    final db = await database;
    final count = await db.update(
      'destinations',
      destination.toMap(),
      where: 'id = ?',
      whereArgs: [destination.id],
    );
    await _refreshDestinations();
    return count;
  }

  Future<void> deleteDestination(int id) async {
    final db = await database;
    await db.delete('destinations', where: 'id = ?', whereArgs: [id]);
    await _refreshDestinations();
  }

  Future<void> clearTable(String table) async {
    final db = await database;
    await db.delete(table);
  }

  // User CRUD Operations
  Future<int> registerUser(User user) async {
    final db = await database;
    try {
      return await db.insert('users', user.toMap());
    } catch (e) {
      return -1; // Duplicate or error
    }
  }

  Future<User?> loginUser(String username, String password) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<User?> getUser(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateUser(User user) async {
    final db = await database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }
}
