import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure/failure.dart';
import '../entities/tenant_entity.dart';
import '../repositories/tenant_repository.dart';

class UpdateTenant {
  final TenantRepository repository;

  UpdateTenant(this.repository);

  Future<Either<Failure, void>> call(TenantEntity tenant) async {
    return await repository.updateTenant(tenant);
  }
}
