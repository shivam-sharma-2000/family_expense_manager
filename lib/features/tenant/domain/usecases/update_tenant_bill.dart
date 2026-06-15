import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure/failure.dart';
import '../entities/tenant_bill_entity.dart';
import '../repositories/tenant_repository.dart';

class UpdateTenantBill {
  final TenantRepository repository;

  UpdateTenantBill(this.repository);

  Future<Either<Failure, void>> call(TenantBillEntity bill) {
    return repository.updateTenantBill(bill);
  }
}
