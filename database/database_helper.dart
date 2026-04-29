import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/todo.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'todo_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE todos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        isDone INTEGER NOT NULL DEFAULT 0,
        createdAt TEXT NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE todos ADD COLUMN priority INTEGER DEFAULT 0',
      );
    }
  }

  // CREATE
  Future<int> insertTodo(Todo todo) async {
    final db = await database;
    return await db.insert(
      'todos',
      todo.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // READ ALL (dengan filter & pencarian)
  Future<List<Todo>> getTodos({
    String? statusFilter, // 'all', 'active', 'completed'
    String? keyword,
  }) async {
    final db = await database;

    final List<String> conditions = [];
    final List<dynamic> args = [];

    if (statusFilter == 'active') {
      conditions.add('isDone = ?');
      args.add(0);
    } else if (statusFilter == 'completed') {
      conditions.add('isDone = ?');
      args.add(1);
    }

    if (keyword != null && keyword.trim().isNotEmpty) {
      conditions.add('title LIKE ?');
      args.add('%${keyword.trim()}%');
    }

    final whereClause =
    conditions.isNotEmpty ? conditions.join(' AND ') : null;

    final List<Map<String, dynamic>> maps = await db.query(
      'todos',
      where: whereClause,
      whereArgs: args.isNotEmpty ? args : null,
      orderBy: 'createdAt DESC',
    );

    return List.generate(maps.length, (i) => Todo.fromMap(maps[i]));
  }

  // READ ALL (tanpa filter, dipertahankan untuk kompatibilitas)
  Future<List<Todo>> getAllTodos() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'todos',
      orderBy: 'createdAt DESC',
    );
    return List.generate(maps.length, (i) => Todo.fromMap(maps[i]));
  }

  // READ BY ID
  Future<Todo?> getTodoById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'todos',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Todo.fromMap(maps.first);
  }

  // UPDATE
  Future<int> updateTodo(Todo todo) async {
    final db = await database;
    return await db.update(
      'todos',
      todo.toMap(),
      where: 'id = ?',
      whereArgs: [todo.id],
    );
  }

  // TOGGLE STATUS
  Future<int> toggleTodoStatus(int id, bool isDone) async {
    final db = await database;
    return await db.update(
      'todos',
      {'isDone': isDone ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // DELETE ONE
  Future<int> deleteTodo(int id) async {
    final db = await database;
    return await db.delete(
      'todos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // DELETE COMPLETED
  Future<int> clearCompletedTodos() async {
    final db = await database;
    return await db.delete(
      'todos',
      where: 'isDone = ?',
      whereArgs: [1],
    );
  }

  // CLOSE (opsional)
  Future<void> closeDatabase() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}