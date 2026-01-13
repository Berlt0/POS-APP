import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AppDatabase {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  static Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'pos.db');

    return await openDatabase(
      path,
      version: 3,
      onCreate: _createTables,
      onUpgrade: (db, oldVersion, newVersion) async {
      if (oldVersion < 3) {
      await db.execute("ALTER TABLE products ADD COLUMN stock_unit TEXT DEFAULT 'pcs'");
      await db.execute("ALTER TABLE products ADD COLUMN cost REAL");
      await db.execute("ALTER TABLE products ADD COLUMN barcode TEXT UNIQUE");
      await db.execute("ALTER TABLE products ADD COLUMN low_stock_alert INTEGER DEFAULT 10");
      await db.execute("ALTER TABLE products ADD COLUMN description TEXT");
      await db.execute("ALTER TABLE products ADD COLUMN image_path TEXT");
      await db.execute("ALTER TABLE products ADD COLUMN createdAt TEXT");
      await db.execute("ALTER TABLE products ADD COLUMN lastUpdate TEXT");
      
      print("Session table altered on upgrade");
      }
    },
      
    );
  }

  static Future<void> _createTables(Database db, int version) async {
    // USERS
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE,
        password TEXT,
        role TEXT,
        token TEXT,
        createdAt TEXT
      )
    ''');

    // PRODUCTS
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        price REAL NOT NULL,
        stock INTEGER NOT NULL,
        stock_unit TEXT DEFAULT 'pcs',
        cost REAL,
        category TEXT,
        barcode TEXT UNIQUE,
        low_stock_alert INTEGER DEFAULT 10,
        description TEXT,
        image_path TEXT,
        createdAt TEXT,
        lastUpdate TEXT

      )
    ''');

    // SALES
    await db.execute('''
      CREATE TABLE sales (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        total REAL,
        created_at TEXT
      )
    ''');

    // SALE ITEMS
    await db.execute('''
      CREATE TABLE sale_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sale_id INTEGER,
        product_id INTEGER,
        quantity INTEGER,
        price REAL
      )
    ''');

    // SESSION (who is logged in)
    await db.execute('''
      CREATE TABLE session (
        id INTEGER PRIMARY KEY,
        user_id INTEGER,
        username TEXT,
        role TEXT,
        login_at TEXT
      )
    ''');

    print("SQLite tables created");
  }

  
}

