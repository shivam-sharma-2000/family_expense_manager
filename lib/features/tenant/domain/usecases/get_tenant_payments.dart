import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure/failure.dart';
import '../entities/tenant_payment_entity.dart';
import '../repositories/tenant_repository.dart';

class GetTenantPayments {
  final TenantRepository repository;

  GetTenantPayments(this.repository);

  Stream<Either<Failure, List<TenantPaymentEntity>>> call(String tenantId) {
    return repository.getTenantPayments(tenantId);
  }
}
