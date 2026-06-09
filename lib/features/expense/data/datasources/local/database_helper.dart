import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static const String _databaseName = 'expense_manager.db';
  static const int _databaseVersion = 5; // Incremented version for schema changes
  
  // Table name
  static const String tableExpenses = 'expenses';
  static const String tableUsers = 'users';
  
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
  static const String columnPaymentMethod = 'payment_method';
  static const String columnIsSynced = 'is_synced';
  static const String columnIsDeleted = 'is_deleted';

  // User Table Columns
  static const String columnUserTableId = 'id';
  static const String columnUserName = 'name';
  static const String columnUserEmail = 'email';
  static const String columnUserPhotoUrl = 'photoUrl';
  static const String columnUserFamilyId = 'familyId';
  static const String columnUserCreatedAt = 'createdAt';
  static const String columnUserUpdatedAt = 'updatedAt';
  
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
        $columnPaymentMethod TEXT,
        $columnIsSynced INTEGER NOT NULL DEFAULT 0,
        $columnIsDeleted INTEGER NOT NULL DEFAULT 0
      )
    ''');
    
    // Create indexes for better query performance
    await db.execute('CREATE INDEX idx_expense_user ON $tableExpenses($columnUserId)');
    await db.execute('CREATE INDEX idx_expense_family ON $tableExpenses($columnFamilyId)');
    
    // Create users table
    await db.execute('''
      CREATE TABLE $tableUsers (
        $columnUserTableId TEXT PRIMARY KEY,
        $columnUserName TEXT NOT NULL,
        $columnUserEmail TEXT NOT NULL,
        $columnUserPhotoUrl TEXT,
        $columnUserFamilyId TEXT,
        $columnUserCreatedAt TEXT,
        $columnUserUpdatedAt TEXT
      )
    ''');
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
    
    if (oldVersion < 4) {
      // Version 4: Drop and recreate table to clear foreign keys, missing columns and old schema issues
      await db.execute('DROP TABLE IF EXISTS $tableExpenses');
      await _onCreate(db, newVersion);
    }
    
    if (oldVersion < 5) {
      // Create users table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $tableUsers (
          $columnUserTableId TEXT PRIMARY KEY,
          $columnUserName TEXT NOT NULL,
          $columnUserEmail TEXT NOT NULL,
          $columnUserPhotoUrl TEXT,
          $columnUserFamilyId TEXT,
          $columnUserCreatedAt TEXT,
          $columnUserUpdatedAt TEXT
        )
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

  // --- USER TABLE METHODS ---

  Future<void> saveUserLocally(Map<String, dynamic> userMap) async {
    final db = await database;
    await db.insert(
      tableUsers,
      userMap,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> getUserLocally(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableUsers,
      where: '$columnUserTableId = ?',
      whereArgs: [userId],
    );
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  Future<void> updateUserLocally(String userId, Map<String, dynamic> data) async {
    final db = await database;
    await db.update(
      tableUsers,
      data,
      where: '$columnUserTableId = ?',
      whereArgs: [userId],
    );
  }
  
  // Close the database connection
  Future<void> close() async {
    final db = await instance.database;
    await db.close();
  }
}
