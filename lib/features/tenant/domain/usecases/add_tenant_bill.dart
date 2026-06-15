import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure/failure.dart';
import '../entities/tenant_bill_entity.dart';
import '../repositories/tenant_repository.dart';

class AddTenantBill {
  final TenantRepository repository;

  AddTenantBill(this.repository);

  Future<Either<Failure, void>> call(TenantBillEntity bill) async {
    return await repository.addTenantBill(bill);
  }
}
