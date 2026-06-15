import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static const String _databaseName = 'expense_manager.db';
  static const int _databaseVersion = 8; // Incremented version for schema changes
  
  // Table name
  static const String tableExpenses = 'expenses';
  static const String tableUsers = 'users';
  static const String tableTenants = 'tenants';
  static const String tableTenantBills = 'tenant_bills';
  static const String tableTenantPayments = 'tenant_payments';
  
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

  // Common Tenant Columns
  static const String columnTenantId = 'tenant_id';
  
  // Tenant Table Columns
  static const String columnTenantName = 'name';
  static const String columnTenantMobile = 'mobile';
  static const String columnTenantAadhaar = 'aadhaar';
  static const String columnTenantFamilyMembers = 'family_members';
  static const String columnTenantRoomNumber = 'room_number';
  static const String columnTenantPhotoPath = 'photo_path';
  static const String columnTenantRent = 'rent';
  static const String columnTenantMaintenance = 'maintenance';
  static const String columnTenantAdvance = 'advance';
  static const String columnTenantRentStartDate = 'rent_start_date';
  static const String columnTenantRentDueDate = 'rent_due_date';
  static const String columnTenantStatus = 'status'; // active, vacated
  static const String columnTenantMeterNumber = 'meter_number';
  static const String columnTenantPreviousReading = 'previous_reading';
  static const String columnTenantUnitRate = 'unit_rate';

  // Tenant Bills Table Columns
  static const String columnBillId = 'bill_id';
  static const String columnBillMonth = 'month';
  static const String columnBillYear = 'year';
  static const String columnBillDate = 'bill_date';
  static const String columnBillRentAmount = 'rent_amount';
  static const String columnBillElectricityUnits = 'electricity_units';
  static const String columnBillElectricityAmount = 'electricity_amount';
  static const String columnBillMaintenanceAmount = 'maintenance_amount';
  static const String columnBillPendingAmount = 'pending_amount';
  static const String columnBillPreviousDue = 'previous_due';
  static const String columnBillPaidAmount = 'paid_amount';
  static const String columnBillAdvanceAdjustment = 'advance_adjustment';
  static const String columnBillTotalAmount = 'total_amount';

  // Tenant Payments Table Columns
  static const String columnPaymentId = 'payment_id';
  static const String columnPaymentDate = 'payment_date';
  static const String columnPaymentAmount = 'amount';
  static const String columnPaymentMode = 'payment_mode';
  static const String columnPaymentNotes = 'notes';
  
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

    // Create tenants table
    await db.execute('''
      CREATE TABLE $tableTenants (
        $columnId TEXT PRIMARY KEY,
        $columnTenantName TEXT NOT NULL,
        $columnTenantMobile TEXT NOT NULL,
        $columnTenantAadhaar TEXT,
        $columnTenantFamilyMembers INTEGER NOT NULL,
        $columnTenantRoomNumber TEXT NOT NULL,
        $columnTenantPhotoPath TEXT,
        $columnTenantRent REAL NOT NULL,
        $columnTenantMaintenance REAL NOT NULL DEFAULT 0,
        $columnTenantAdvance REAL NOT NULL DEFAULT 0,
        $columnTenantRentStartDate INTEGER NOT NULL,
        $columnTenantRentDueDate INTEGER NOT NULL,
        $columnTenantStatus TEXT NOT NULL,
        $columnTenantMeterNumber TEXT,
        $columnTenantPreviousReading REAL NOT NULL DEFAULT 0,
        $columnTenantUnitRate REAL NOT NULL DEFAULT 0,
        $columnUserId TEXT NOT NULL,
        $columnFamilyId TEXT NOT NULL,
        $columnIsSynced INTEGER NOT NULL DEFAULT 0,
        $columnIsDeleted INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Create tenant bills table
    await db.execute('''
      CREATE TABLE $tableTenantBills (
        $columnBillId TEXT PRIMARY KEY,
        $columnTenantId TEXT NOT NULL,
        $columnBillMonth INTEGER NOT NULL,
        $columnBillYear INTEGER NOT NULL,
        $columnBillDate INTEGER NOT NULL DEFAULT 0,
        $columnBillRentAmount REAL NOT NULL,
        $columnBillElectricityUnits REAL NOT NULL DEFAULT 0,
        $columnBillElectricityAmount REAL NOT NULL DEFAULT 0,
        $columnBillMaintenanceAmount REAL NOT NULL DEFAULT 0,
        $columnBillPendingAmount REAL NOT NULL DEFAULT 0,
        $columnBillPreviousDue REAL NOT NULL DEFAULT 0,
        $columnBillPaidAmount REAL NOT NULL DEFAULT 0,
        $columnBillAdvanceAdjustment REAL NOT NULL DEFAULT 0,
        $columnBillTotalAmount REAL NOT NULL,
        $columnUserId TEXT NOT NULL,
        $columnFamilyId TEXT NOT NULL,
        $columnIsSynced INTEGER NOT NULL DEFAULT 0,
        $columnIsDeleted INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Create tenant payments table
    await db.execute('''
      CREATE TABLE $tableTenantPayments (
        $columnPaymentId TEXT PRIMARY KEY,
        $columnTenantId TEXT NOT NULL,
        $columnBillId TEXT NOT NULL,
        $columnPaymentDate INTEGER NOT NULL,
        $columnPaymentAmount REAL NOT NULL,
        $columnPaymentMode TEXT NOT NULL,
        $columnPaymentNotes TEXT,
        $columnUserId TEXT NOT NULL,
        $columnFamilyId TEXT NOT NULL,
        $columnIsSynced INTEGER NOT NULL DEFAULT 0,
        $columnIsDeleted INTEGER NOT NULL DEFAULT 0
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

    if (oldVersion < 6) {
      // Create tenants table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $tableTenants (
          $columnId TEXT PRIMARY KEY,
          $columnTenantName TEXT NOT NULL,
          $columnTenantMobile TEXT NOT NULL,
          $columnTenantAadhaar TEXT,
          $columnTenantFamilyMembers INTEGER NOT NULL,
          $columnTenantRoomNumber TEXT NOT NULL,
          $columnTenantPhotoPath TEXT,
          $columnTenantRent REAL NOT NULL,
          $columnTenantMaintenance REAL NOT NULL DEFAULT 0,
          $columnTenantAdvance REAL NOT NULL DEFAULT 0,
          $columnTenantRentStartDate INTEGER NOT NULL,
          $columnTenantRentDueDate INTEGER NOT NULL,
          $columnTenantStatus TEXT NOT NULL,
          $columnTenantMeterNumber TEXT,
          $columnTenantPreviousReading REAL NOT NULL DEFAULT 0,
          $columnTenantUnitRate REAL NOT NULL DEFAULT 0,
          $columnUserId TEXT NOT NULL,
          $columnFamilyId TEXT NOT NULL,
          $columnIsSynced INTEGER NOT NULL DEFAULT 0,
          $columnIsDeleted INTEGER NOT NULL DEFAULT 0
        )
      ''');

      // Create tenant bills table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $tableTenantBills (
          $columnBillId TEXT PRIMARY KEY,
          $columnTenantId TEXT NOT NULL,
          $columnBillMonth INTEGER NOT NULL,
          $columnBillYear INTEGER NOT NULL,
          $columnBillDate INTEGER NOT NULL DEFAULT 0,
          $columnBillRentAmount REAL NOT NULL,
          $columnBillElectricityUnits REAL NOT NULL DEFAULT 0,
          $columnBillElectricityAmount REAL NOT NULL DEFAULT 0,
          $columnBillMaintenanceAmount REAL NOT NULL DEFAULT 0,
          $columnBillPendingAmount REAL NOT NULL DEFAULT 0,
          $columnBillPreviousDue REAL NOT NULL DEFAULT 0,
          $columnBillPaidAmount REAL NOT NULL DEFAULT 0,
          $columnBillAdvanceAdjustment REAL NOT NULL DEFAULT 0,
          $columnBillTotalAmount REAL NOT NULL,
          $columnUserId TEXT NOT NULL,
          $columnFamilyId TEXT NOT NULL,
          $columnIsSynced INTEGER NOT NULL DEFAULT 0,
          $columnIsDeleted INTEGER NOT NULL DEFAULT 0
        )
      ''');

      // Create tenant payments table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $tableTenantPayments (
          $columnPaymentId TEXT PRIMARY KEY,
          $columnTenantId TEXT NOT NULL,
          $columnBillId TEXT NOT NULL,
          $columnPaymentDate INTEGER NOT NULL,
          $columnPaymentAmount REAL NOT NULL,
          $columnPaymentMode TEXT NOT NULL,
          $columnPaymentNotes TEXT,
          $columnUserId TEXT NOT NULL,
          $columnFamilyId TEXT NOT NULL,
          $columnIsSynced INTEGER NOT NULL DEFAULT 0,
          $columnIsDeleted INTEGER NOT NULL DEFAULT 0
        )
      ''');
    }

    if (oldVersion < 7) {
      try {
        await db.execute('''
          ALTER TABLE $tableTenantBills 
          ADD COLUMN $columnBillDate INTEGER NOT NULL DEFAULT 0
        ''');
      } catch (e) {
        // Ignore duplicate column error if already created
      }
    }

    if (oldVersion < 8) {
      try {
        await db.execute('''
          ALTER TABLE $tableTenantPayments 
          ADD COLUMN $columnBillId TEXT NOT NULL DEFAULT ''
        ''');
      } catch (e) {}
      
      try {
        await db.execute('''
          ALTER TABLE $tableTenantBills 
          ADD COLUMN $columnBillPreviousDue REAL NOT NULL DEFAULT 0
        ''');
      } catch (e) {}
      
      try {
        await db.execute('''
          ALTER TABLE $tableTenantBills 
          ADD COLUMN $columnBillPaidAmount REAL NOT NULL DEFAULT 0
        ''');
      } catch (e) {}
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
