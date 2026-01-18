import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static const String _databaseName = 'expense_manager.db';
  static const int _databaseVersion = 2; // Incremented version for schema changes
  
  // Table name
  static const String tableExpenses = 'expenses';
  
  // Expense Table Columns
  static const String columnId = 'id';
  static const String columnTitle = 'title';
  static const String columnAmount = 'amount';
  static const String columnDate = 'date';
  static const String columnCategory = 'category';
  static const String columnDescription = 'description';
  static const String columnReceiptImagePath = 'receipt_image_path';
  static const String columnUserId = 'user_id';
  static const String columnFamilyId = 'family_id';
  static const String columnIsSynced = 'is_synced';
  static const String columnIsDeleted = 'is_deleted';
  
  // Make this a singleton class
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  
  // Only allow a single open connection to the database
  static Database? _database;
  
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
  
  // Initialize the database
  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);
    
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  
  // Create the database tables
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableExpenses (
        $columnId TEXT PRIMARY KEY,
        $columnTitle TEXT NOT NULL,
        $columnAmount REAL NOT NULL,
        $columnDate INTEGER NOT NULL,
        $columnCategory TEXT NOT NULL,
        $columnDescription TEXT,
        $columnReceiptImagePath TEXT,
        $columnUserId TEXT NOT NULL,
        $columnFamilyId TEXT NOT NULL,
        $columnIsSynced INTEGER NOT NULL DEFAULT 0,
        $columnIsDeleted INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY ($columnUserId) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY ($columnFamilyId) REFERENCES families(id) ON DELETE CASCADE
      )
    ''');
    
    // Create indexes for better query performance
    await db.execute('CREATE INDEX idx_expense_user ON $tableExpenses($columnUserId)');
    await db.execute('CREATE INDEX idx_expense_family ON $tableExpenses($columnFamilyId)');
  }
  
  // Handle database upgrades
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add is_synced and is_deleted columns if they don't exist
      await db.execute('''
        ALTER TABLE $tableExpenses 
        ADD COLUMN $columnIsSynced INTEGER NOT NULL DEFAULT 1
      ''');
      
      await db.execute('''
        ALTER TABLE $tableExpenses 
        ADD COLUMN $columnIsDeleted INTEGER NOT NULL DEFAULT 0
      ''');
      
      // Add user_id and family_id columns with default values
      await db.execute('''
        ALTER TABLE $tableExpenses 
        ADD COLUMN $columnUserId TEXT NOT NULL DEFAULT 'default_user_id'
      ''');
      
      await db.execute('''
        ALTER TABLE $tableExpenses 
        ADD COLUMN $columnFamilyId TEXT NOT NULL DEFAULT 'default_family_id'
      ''');
    }
  }

  // Get all unsynced expenses
  Future<List<Map<String, dynamic>>> getUnsyncedExpenses() async {
    final db = await database;
    return await db.query(
      tableExpenses,
      where: '$columnIsSynced = ? AND $columnIsDeleted = ?',
      whereArgs: [0, 0],
    );
  }

  // Get all deleted but not synced expenses
  Future<List<Map<String, dynamic>>> getDeletedButNotSynced() async {
    final db = await database;
    return await db.query(
      tableExpenses,
      where: '$columnIsDeleted = ? AND $columnIsSynced = ?',
      whereArgs: [1, 0],
    );
  }

  // Mark an expense as synced
  Future<void> markAsSynced(String id) async {
    final db = await database;
    await db.update(
      tableExpenses,
      {columnIsSynced: 1},
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  // Get all expenses including deleted for sync
  Future<List<Map<String, dynamic>>> getAllExpensesForSync() async {
    final db = await database;
    return await db.query(tableExpenses);
  }
  
  // Close the database connection
  Future<void> close() async {
    final db = await instance.database;
    await db.close();
  }
}
