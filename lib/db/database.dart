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
      version: 5,
      onOpen: (db) async{
        await db.execute("PRAGMA foreign_keys = ON");
      },
      onCreate: _createTables,
      onUpgrade: (db, oldVersion, newVersion) async {
      if (oldVersion < 5) {

       await db.execute("ALTER TABLE sales ADD COLUMN payment_type TEXT DEFAULT 'cash'");
      
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
        user_id INTEGER NOT NULL,
        total_amount REAL NOT NULL,
        amount_received REAL NOT NULL,
        change_amount REAL NOT NULL,
        payment_type TEXT DEFAULT 'cash',
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,

        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');

    // SALE ITEMS
    await db.execute('''
      CREATE TABLE sale_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sale_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        product_name TEXT NOT NULL,
        price REAL NOT NULL,
        quantity INTEGER NOT NULL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
      
        FOREIGN KEY (sale_id) REFERENCES sales(id) ON DELETE CASCADE,
        FOREIGN KEY (product_id) REFERENCES products(id)
      )

    ''');


    await db.execute('''
     CREATE TABLE transaction_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        action TEXT NOT NULL,
        entity_type TEXT,      -- 'sale', 'product'
        entity_id INTEGER,     -- nullable
        description TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,

        FOREIGN KEY (user_id) REFERENCES users(id)
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

