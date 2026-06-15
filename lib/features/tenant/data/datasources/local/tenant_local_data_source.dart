import '../../models/tenant_model.dart';
import '../../models/tenant_bill_model.dart';
import '../../models/tenant_payment_model.dart';

abstract class TenantLocalDataSource {
  Future<void> addTenant(TenantModel tenant);
  Future<void> updateTenant(TenantModel tenant);
  Stream<List<TenantModel>> getTenants();

  Future<void> addTenantBill(TenantBillModel bill);
  Future<void> updateTenantBill(TenantBillModel bill);
  Stream<List<TenantBillModel>> getTenantBills(String tenantId);

  Future<void> addTenantPayment(TenantPaymentModel payment);
  Stream<List<TenantPaymentModel>> getTenantPayments(String tenantId);

  Future<List<TenantModel>> getUnsyncedTenants();
  Future<List<TenantBillModel>> getUnsyncedTenantBills();
  Future<List<TenantPaymentModel>> getUnsyncedTenantPayments();
  
  Future<void> clearAllTenantData();
  
  Future<void> markTenantAsSynced(String id);
  Future<void> markTenantBillAsSynced(String id);
  Future<void> markTenantPaymentAsSynced(String id);
}
