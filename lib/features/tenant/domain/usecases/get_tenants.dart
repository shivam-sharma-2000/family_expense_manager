import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure/failure.dart';
import '../entities/tenant_entity.dart';
import '../repositories/tenant_repository.dart';

class GetTenants {
  final TenantRepository repository;

  GetTenants(this.repository);

  Stream<Either<Failure, List<TenantEntity>>> call() {
    return repository.getTenants();
  }
}
