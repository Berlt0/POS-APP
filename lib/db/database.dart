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
      version: 8,
      onOpen: (db) async{
        await db.execute("PRAGMA foreign_keys = ON");
      },
      onCreate: _createTables,
      onUpgrade: (db, oldVersion, newVersion) async {
      if (oldVersion < 8) {


       print("Offline-first columns added");
      }
    },
      
    );
  }

  static Future<void> _createTables(Database db, int version) async {
    // USERS
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        global_id TEXT UNIQUE,

        username TEXT UNIQUE,
        password TEXT,
        role TEXT,
        name TEXT,
        email TEXT,
        contact_number TEXT,
        address TEXT,
        createdAt TEXT,
        is_synced INTEGER DEFAULT 0
      )
    ''');

    // PRODUCTS
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        global_id TEXT UNIQUE,

        name TEXT NOT NULL,
        price REAL NOT NULL,
        stock INTEGER NOT NULL,
        stock_unit TEXT DEFAULT 'pcs',
        cost REAL,
        category TEXT,
        barcode TEXT UNIQUE,
        low_stock_alert INTEGER DEFAULT 5,
        description TEXT,
        image_path TEXT,
        createdAt TEXT,
        is_synced INTEGER DEFAULT 0,
        updated_at TEXT,
        deleted_at TEXT
      )
    ''');


    // SALES
    await db.execute('''
      CREATE TABLE sales (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        global_id TEXT UNIQUE,

        user_id INTEGER NOT NULL,
        user_global_id TEXT,

        total_amount REAL NOT NULL,
        amount_received REAL NOT NULL,
        change_amount REAL NOT NULL,
        status TEXT,
        voided_at TEXT,
        voided_by TEXT,
        reason TEXT,
        payment_type TEXT DEFAULT 'cash',
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        is_synced INTEGER DEFAULT 0,
      

        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');

    // SALE ITEMS
    await db.execute('''
      CREATE TABLE sale_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        global_id TEXT UNIQUE,
        
        sale_id INTEGER NOT NULL,
        sale_global_id TEXT,

        product_id INTEGER,
        product_global_id TEXT,

        product_name TEXT NOT NULL,
        price REAL NOT NULL,
        quantity INTEGER NOT NULL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        is_synced INTEGER DEFAULT 0,
      
        FOREIGN KEY (sale_id) REFERENCES sales(id) ON DELETE CASCADE
       
        
      )

    ''');



    await db.execute('''
     CREATE TABLE transaction_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        global_id TEXT UNIQUE,
        
        user_id INTEGER NOT NULL,
        user_global_id TEXT,

        action TEXT NOT NULL,
        entity_type TEXT,      -- 'sale', 'product'
        entity_id INTEGER,     -- nullable
        description TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        is_synced INTEGER DEFAULT 0,

        FOREIGN KEY (user_id) REFERENCES users(id)
    
      )
    ''');

    // SESSION (who is logged in)
    await db.execute('''
      CREATE TABLE session (
        id INTEGER PRIMARY KEY,
        user_id INTEGER,
        user_global_id,
        username TEXT,
        role TEXT,
        login_at TEXT,
        is_synced INTEGER DEFAULT 0
      )
      ''');
    
    await db.execute(
    '''
      CREATE TABLE products_archive (
        id INTEGER PRIMARY KEY,
        global_id TEXT UNIQUE,

        name TEXT NOT NULL,
        price REAL NOT NULL,
        stock INTEGER NOT NULL,
        stock_unit TEXT DEFAULT 'pcs',
        cost REAL,
        category TEXT,
        barcode TEXT UNIQUE,
        low_stock_alert INTEGER DEFAULT 5,
        description TEXT,
        image_path TEXT,
        createdAt TEXT,
        is_synced INTEGER DEFAULT 0,
        updated_at TEXT,
        deleted_at TEXT
      )'''
      );

      // Sales
      await db.execute('CREATE INDEX idx_sales_status ON sales(status)');
      await db.execute('CREATE INDEX idx_sales_created_status ON sales(created_at, status)');
      await db.execute('CREATE INDEX idx_sales_user_id ON sales(user_id)');

      // Sale Items
      await db.execute('CREATE INDEX idx_sale_items_sale_id ON sale_items(sale_id)');
      await db.execute('CREATE INDEX idx_sale_items_product_id ON sale_items(product_id)');

      // Products
      await db.execute('CREATE INDEX idx_products_category ON products(category)');
      await db.execute('CREATE INDEX idx_products_name ON products(name)');
      await db.execute('CREATE INDEX idx_products_barcode ON products(barcode)');
      await db.execute('CREATE INDEX idx_products_deleted_at ON products(deleted_at)');

      // Transaction History
      await db.execute('CREATE INDEX idx_transaction_created_at ON transaction_history(created_at)');
      await db.execute('CREATE INDEX idx_transaction_user_id ON transaction_history(user_id)');
      await db.execute('CREATE INDEX idx_transaction_entity_type ON transaction_history(entity_type)');

      // Users
      await db.execute('CREATE INDEX idx_users_username ON users(username)');

      // Products Archive
      await db.execute('CREATE INDEX idx_archive_deleted_at ON products_archive(deleted_at)');
      await db.execute('CREATE INDEX idx_archive_barcode ON products_archive(barcode)');


    print("SQLite tables created");
  }

  
}

