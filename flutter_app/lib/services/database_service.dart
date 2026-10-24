import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/chat_message.dart';
import '../models/user_memory.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('jx_companion.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    // Chat History Table
    await db.execute('''
      CREATE TABLE chat_messages (
        id TEXT PRIMARY KEY,
        text TEXT NOT NULL,
        sender TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        emotion TEXT NOT NULL,
        audioPath TEXT
      )
    ''');

    // Memory Storage Table
    await db.execute('''
      CREATE TABLE user_memories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        key TEXT NOT NULL UNIQUE,
        value TEXT NOT NULL,
        category TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    // Preseed Gowrob & JX default context memory
    await db.insert('user_memories', {
      'key': 'creator_name',
      'value': 'Gowrob',
      'category': 'identity',
      'updatedAt': DateTime.now().toIso8601String(),
    });
    await db.insert('user_memories', {
      'key': 'companion_name',
      'value': 'JX',
      'category': 'identity',
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  // --- Chat Messages Methods ---
  Future<void> insertMessage(ChatMessage message) async {
    final db = await instance.database;
    await db.insert(
      'chat_messages',
      message.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ChatMessage>> getMessages({int limit = 50}) async {
    final db = await instance.database;
    final maps = await db.query(
      'chat_messages',
      orderBy: 'timestamp ASC',
      limit: limit,
    );
    return maps.map((map) => ChatMessage.fromMap(map)).toList();
  }

  // --- Memory Methods ---
  Future<void> saveMemory(String key, String value, {String category = 'preference'}) async {
    final db = await instance.database;
    await db.insert(
      'user_memories',
      {
        'key': key,
        'value': value,
        'category': category,
        'updatedAt': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<UserMemory>> getAllMemories() async {
    final db = await instance.database;
    final maps = await db.query('user_memories', orderBy: 'updatedAt DESC');
    return maps.map((m) => UserMemory.fromMap(m)).toList();
  }

  Future<void> deleteMemory(String key) async {
    final db = await instance.database;
    await db.delete('user_memories', where: 'key = ?', whereArgs: [key]);
  }

  Future<void> clearAllMemory() async {
    final db = await instance.database;
    await db.delete('user_memories');
    await db.delete('chat_messages');
  }
}
