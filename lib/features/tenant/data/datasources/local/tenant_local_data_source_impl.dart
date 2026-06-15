import 'dart:async';
import 'package:sqflite/sqflite.dart';
import '../../../../expense/data/datasources/local/database_helper.dart';
import '../../models/tenant_model.dart';
import '../../models/tenant_bill_model.dart';
import '../../models/tenant_payment_model.dart';
import 'tenant_local_data_source.dart';

class TenantLocalDataSourceImpl implements TenantLocalDataSource {
  final DatabaseHelper databaseHelper;

  // Stream controllers to provide reactive updates
  final _tenantsController = StreamController<List<TenantModel>>.broadcast();
  final _tenantBillsController = StreamController<List<TenantBillModel>>.broadcast();
  final _tenantPaymentsController = StreamController<List<TenantPaymentModel>>.broadcast();

  TenantLocalDataSourceImpl(this.databaseHelper) {
    _notifyTenantsChanged();
    _notifyBillsChanged();
    _notifyPaymentsChanged();
  }

  // --- Tenants ---

  Future<void> _notifyTenantsChanged() async {
    final db = await databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableTenants,
      where: '${DatabaseHelper.columnIsDeleted} = ?',
      whereArgs: [0],
    );
    final tenants = maps.map((map) => TenantModel.fromMap(map)).toList();
    _tenantsController.add(tenants);
  }

  @override
  Future<void> addTenant(TenantModel tenant) async {
    final db = await databaseHelper.database;
    await db.insert(
      DatabaseHelper.tableTenants,
      tenant.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await _notifyTenantsChanged();
  }

  @override
  Future<void> updateTenant(TenantModel tenant) async {
    final db = await databaseHelper.database;
    await db.update(
      DatabaseHelper.tableTenants,
      tenant.toMap(),
      where: '${DatabaseHelper.columnId} = ?',
      whereArgs: [tenant.id],
    );
    await _notifyTenantsChanged();
  }

  @override
  Stream<List<TenantModel>> getTenants() {
    _notifyTenantsChanged();
    return _tenantsController.stream;
  }

  // --- Bills ---

  Future<void> _notifyBillsChanged() async {
    final db = await databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableTenantBills,
      where: '${DatabaseHelper.columnIsDeleted} = ?',
      whereArgs: [0],
    );
    final bills = maps.map((map) => TenantBillModel.fromMap(map)).toList();
    _tenantBillsController.add(bills);
  }

  @override
  Future<void> addTenantBill(TenantBillModel bill) async {
    final db = await databaseHelper.database;
    await db.insert(
      DatabaseHelper.tableTenantBills,
      bill.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await _notifyBillsChanged();
  }

  @override
  Future<void> updateTenantBill(TenantBillModel bill) async {
    final db = await databaseHelper.database;
    await db.update(
      DatabaseHelper.tableTenantBills,
      bill.toMap(),
      where: '${DatabaseHelper.columnBillId} = ?',
      whereArgs: [bill.id],
    );
    await _notifyBillsChanged();
  }

  @override
  Stream<List<TenantBillModel>> getTenantBills(String tenantId) {
    _notifyBillsChanged();
    return _tenantBillsController.stream.map(
      (bills) => bills.where((b) => b.tenantId == tenantId).toList()..sort((a, b) {
        if (a.year != b.year) return b.year.compareTo(a.year);
        return b.month.compareTo(a.month);
      }),
    );
  }

  // --- Payments ---

  Future<void> _notifyPaymentsChanged() async {
    final db = await databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableTenantPayments,
      where: '${DatabaseHelper.columnIsDeleted} = ?',
      whereArgs: [0],
    );
    final payments = maps.map((map) => TenantPaymentModel.fromMap(map)).toList();
    _tenantPaymentsController.add(payments);
  }

  @override
  Future<void> addTenantPayment(TenantPaymentModel payment) async {
    final db = await databaseHelper.database;
    await db.insert(
      DatabaseHelper.tableTenantPayments,
      payment.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await _notifyPaymentsChanged();
  }

  @override
  Stream<List<TenantPaymentModel>> getTenantPayments(String tenantId) {
    _notifyPaymentsChanged();
    return _tenantPaymentsController.stream.map(
      (payments) => payments.where((p) => p.tenantId == tenantId).toList()..sort((a, b) => b.date.compareTo(a.date)),
    );
  }

  // --- Syncing Methods ---

  @override
  Future<List<TenantModel>> getUnsyncedTenants() async {
    final db = await databaseHelper.database;
    final maps = await db.query(
      DatabaseHelper.tableTenants,
      where: '${DatabaseHelper.columnIsSynced} = ?',
      whereArgs: [0],
    );
    return maps.map((e) => TenantModel.fromMap(e)).toList();
  }

  @override
  Future<List<TenantBillModel>> getUnsyncedTenantBills() async {
    final db = await databaseHelper.database;
    final maps = await db.query(
      DatabaseHelper.tableTenantBills,
      where: '${DatabaseHelper.columnIsSynced} = ?',
      whereArgs: [0],
    );
    return maps.map((e) => TenantBillModel.fromMap(e)).toList();
  }

  @override
  Future<List<TenantPaymentModel>> getUnsyncedTenantPayments() async {
    final db = await databaseHelper.database;
    final maps = await db.query(
      DatabaseHelper.tableTenantPayments,
      where: '${DatabaseHelper.columnIsSynced} = ?',
      whereArgs: [0],
    );
    return maps.map((e) => TenantPaymentModel.fromMap(e)).toList();
  }

  @override
  Future<void> markTenantAsSynced(String id) async {
    final db = await databaseHelper.database;
    await db.update(DatabaseHelper.tableTenants, {DatabaseHelper.columnIsSynced: 1}, where: '${DatabaseHelper.columnId} = ?', whereArgs: [id]);
  }

  @override
  Future<void> markTenantBillAsSynced(String id) async {
    final db = await databaseHelper.database;
    await db.update(DatabaseHelper.tableTenantBills, {DatabaseHelper.columnIsSynced: 1}, where: '${DatabaseHelper.columnBillId} = ?', whereArgs: [id]);
  }

  @override
  Future<void> markTenantPaymentAsSynced(String id) async {
    final db = await databaseHelper.database;
    await db.update(
      DatabaseHelper.tableTenantPayments,
      {DatabaseHelper.columnIsSynced: 1},
      where: '${DatabaseHelper.columnPaymentId} = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> clearAllTenantData() async {
    final db = await databaseHelper.database;
    await db.delete(DatabaseHelper.tableTenants);
    await db.delete(DatabaseHelper.tableTenantBills);
    await db.delete(DatabaseHelper.tableTenantPayments);
    
    // Notify all listeners that data has been cleared
    await _notifyTenantsChanged();
    await _notifyBillsChanged();
    await _notifyPaymentsChanged();
  }
}
