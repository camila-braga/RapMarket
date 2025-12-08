import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._init();
  static Database? _database;

  DBHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('rapmarket.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const realType = 'REAL NOT NULL';
    const integerType = 'INTEGER NOT NULL';

    await db.execute('''
      CREATE TABLE lists ( 
        id $idType, 
        title $textType,
        created_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE items ( 
        id $idType, 
        list_id $integerType,
        name $textType,
        price $realType,
        category $textType,
        is_bought $integerType
      )
    ''');
  }

  // ------------------------------
  // CRUD LISTAS
  // ------------------------------

  Future<int> createList(String title) async {
    final db = await instance.database;
    final data = {
      'title': title,
      'created_at': DateTime.now().toIso8601String(),
    };
    return await db.insert('lists', data);
  }

  Future<List<Map<String, dynamic>>> getAllLists() async {
    final db = await instance.database;
    return await db.query('lists', orderBy: 'created_at DESC');
  }

  Future<int> deleteList(int id) async {
    final db = await instance.database;

    await db.delete('items', where: 'list_id = ?', whereArgs: [id]);
    return await db.delete('lists', where: 'id = ?', whereArgs: [id]);
  }

  // ------------------------------
  // CRUD ITENS
  // ------------------------------

  Future<int> addItem(int listId, String name, double price, String category) async {
    final db = await instance.database;
    final data = {
      'list_id': listId,
      'name': name,
      'price': price,
      'category': category,
      'is_bought': 0,
    };
    return await db.insert('items', data);
  }

  Future<List<Map<String, dynamic>>> getItems(int listId) async {
    final db = await instance.database;
    return await db.query('items', where: 'list_id = ?', whereArgs: [listId]);
  }

  Future<int> toggleItemStatus(int id, bool currentStatus) async {
    final db = await instance.database;
    return await db.update(
      'items',
      {'is_bought': currentStatus ? 0 : 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteItem(int id) async {
    final db = await instance.database;
    return await db.delete('items', where: 'id = ?', whereArgs: [id]);
  }
}
