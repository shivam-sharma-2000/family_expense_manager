import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure/failure.dart';
import '../entities/tenant_payment_entity.dart';
import '../repositories/tenant_repository.dart';

class AddTenantPayment {
  final TenantRepository repository;

  AddTenantPayment(this.repository);

  Future<Either<Failure, void>> call(TenantPaymentEntity payment) async {
    return await repository.addTenantPayment(payment);
  }
}
