import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static const String _databaseName = 'expense_manager.db';
  static const int _databaseVersion = 1;
  
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
        $columnReceiptImagePath TEXT
      )
    ''');
  }
  
  // Close the database connection
  Future<void> close() async {
    final db = await instance.database;
    await db.close();
  }
}
