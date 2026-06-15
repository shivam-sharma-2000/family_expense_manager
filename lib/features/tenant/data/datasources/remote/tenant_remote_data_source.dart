import '../../models/tenant_model.dart';
import '../../models/tenant_bill_model.dart';
import '../../models/tenant_payment_model.dart';

abstract class TenantRemoteDataSource {
  Future<void> syncTenants(List<TenantModel> tenants, String familyId, String userId);
  Future<void> syncTenantBills(List<TenantBillModel> bills, String familyId, String userId);
  Future<void> syncTenantPayments(List<TenantPaymentModel> payments, String familyId, String userId);
  
  Future<List<TenantModel>> getTenants(String familyId, String userId);
  Future<List<TenantBillModel>> getTenantBills(String familyId, String userId);
  Future<List<TenantPaymentModel>> getTenantPayments(String familyId, String userId);
}
