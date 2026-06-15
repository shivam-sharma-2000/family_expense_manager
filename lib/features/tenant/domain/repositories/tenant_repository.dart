import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure/failure.dart';
import '../entities/tenant_entity.dart';
import '../entities/tenant_bill_entity.dart';
import '../entities/tenant_payment_entity.dart';

abstract class TenantRepository {
  // Tenant Operations
  Future<Either<Failure, void>> addTenant(TenantEntity tenant);
  Future<Either<Failure, void>> updateTenant(TenantEntity tenant);
  Stream<Either<Failure, List<TenantEntity>>> getTenants();
  
  // Billing Operations
  Future<Either<Failure, void>> addTenantBill(TenantBillEntity bill);
  Future<Either<Failure, void>> updateTenantBill(TenantBillEntity bill);
  Stream<Either<Failure, List<TenantBillEntity>>> getTenantBills(String tenantId);

  // Payment Operations
  Future<Either<Failure, void>> addTenantPayment(TenantPaymentEntity payment);
  Stream<Either<Failure, List<TenantPaymentEntity>>> getTenantPayments(String tenantId);

  // Sync
  Future<Either<Failure, void>> syncWithFirebase();
}
