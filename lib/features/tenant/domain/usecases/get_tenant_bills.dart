import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure/failure.dart';
import '../entities/tenant_bill_entity.dart';
import '../repositories/tenant_repository.dart';

class GetTenantBills {
  final TenantRepository repository;

  GetTenantBills(this.repository);

  Stream<Either<Failure, List<TenantBillEntity>>> call(String tenantId) {
    return repository.getTenantBills(tenantId);
  }
}
