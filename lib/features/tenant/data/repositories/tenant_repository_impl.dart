import 'package:expense_manager/core/service/i_local_storage_service.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure/failure.dart';
import '../../domain/entities/tenant_entity.dart';
import '../../domain/entities/tenant_bill_entity.dart';
import '../../domain/entities/tenant_payment_entity.dart';
import '../../domain/repositories/tenant_repository.dart';
import '../datasources/local/tenant_local_data_source.dart';
import '../datasources/remote/tenant_remote_data_source.dart';
import '../models/tenant_model.dart';
import '../models/tenant_bill_model.dart';
import '../models/tenant_payment_model.dart';

class TenantRepositoryImpl implements TenantRepository {
  final TenantLocalDataSource localDataSource;
  final TenantRemoteDataSource remoteDataSource;
  final ILocalStorageService localStorageService;

  TenantRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.localStorageService,
  });

  @override
  Future<Either<Failure, void>> addTenant(TenantEntity tenant) async {
    try {
      await localDataSource.addTenant(TenantModel.fromEntity(tenant));
      return const Right(null);
    } catch (e) {
      return const Left(UnexpectedFailure(description: 'Failed to add tenant'));
    }
  }

  @override
  Future<Either<Failure, void>> updateTenant(TenantEntity tenant) async {
    try {
      await localDataSource.updateTenant(TenantModel.fromEntity(tenant));
      return const Right(null);
    } catch (e) {
      return const Left(UnexpectedFailure(description: 'Failed to update tenant'));
    }
  }

  @override
  Stream<Either<Failure, List<TenantEntity>>> getTenants() {
    return localDataSource.getTenants().map((models) => Right(models));
  }

  @override
  Future<Either<Failure, void>> addTenantBill(TenantBillEntity bill) async {
    try {
      await localDataSource.addTenantBill(TenantBillModel.fromEntity(bill));
      return const Right(null);
    } catch (e) {
      return const Left(UnexpectedFailure(description: 'Failed to add tenant bill'));
    }
  }

  @override
  Future<Either<Failure, void>> updateTenantBill(TenantBillEntity bill) async {
    try {
      await localDataSource.updateTenantBill(TenantBillModel.fromEntity(bill));
      return const Right(null);
    } catch (e) {
      return const Left(UnexpectedFailure(description: 'Failed to update tenant bill'));
    }
  }

  @override
  Stream<Either<Failure, List<TenantBillEntity>>> getTenantBills(
    String tenantId,
  ) {
    return localDataSource
        .getTenantBills(tenantId)
        .map((models) => Right(models));
  }

  @override
  Future<Either<Failure, void>> addTenantPayment(
    TenantPaymentEntity payment,
  ) async {
    try {
      await localDataSource.addTenantPayment(
        TenantPaymentModel.fromEntity(payment),
      );

      return const Right(null);
    } catch (e) {
      return const Left(UnexpectedFailure(description: 'Failed to add tenant payment'));
    }
  }

  @override
  Stream<Either<Failure, List<TenantPaymentEntity>>> getTenantPayments(
    String tenantId,
  ) {
    return localDataSource
        .getTenantPayments(tenantId)
        .map((models) => Right(models));
  }

  @override
  Future<Either<Failure, void>> syncWithFirebase() async {
    try {
      final familyId = await localStorageService.familyId ?? '';
      final userId = await localStorageService.userId;
      
      if (userId == null || userId.isEmpty) {
        return const Left(UnexpectedFailure(description: 'No user ID found'));
      }

      // 1. Push local changes
      final unsyncedTenants = await localDataSource.getUnsyncedTenants();
      final unsyncedBills = await localDataSource.getUnsyncedTenantBills();
      final unsyncedPayments = await localDataSource.getUnsyncedTenantPayments();

      if (unsyncedTenants.isNotEmpty) {
        await remoteDataSource.syncTenants(unsyncedTenants, familyId, userId);
        for (var t in unsyncedTenants) {
          await localDataSource.markTenantAsSynced(t.id);
        }
      }

      if (unsyncedBills.isNotEmpty) {
        await remoteDataSource.syncTenantBills(unsyncedBills, familyId, userId);
        for (var b in unsyncedBills) {
          await localDataSource.markTenantBillAsSynced(b.id);
        }
      }

      if (unsyncedPayments.isNotEmpty) {
        await remoteDataSource.syncTenantPayments(unsyncedPayments, familyId, userId);
        for (var p in unsyncedPayments) {
          await localDataSource.markTenantPaymentAsSynced(p.id);
        }
      }

      // 2. Pull remote changes
      final remoteTenants = await remoteDataSource.getTenants(familyId, userId);
      final remoteBills = await remoteDataSource.getTenantBills(familyId, userId);
      final remotePayments = await remoteDataSource.getTenantPayments(familyId, userId);

      await localDataSource.clearAllTenantData();

      for (var t in remoteTenants) {
        final syncedModel = TenantModel.fromMap({...t.toMap(), 'is_synced': 1});
        await localDataSource.addTenant(syncedModel);
      }

      for (var b in remoteBills) {
        final syncedModel = TenantBillModel.fromMap({
          ...b.toMap(),
          'is_synced': 1,
        });
        await localDataSource.addTenantBill(syncedModel);
      }

      for (var p in remotePayments) {
        final syncedModel = TenantPaymentModel.fromMap({
          ...p.toMap(),
          'is_synced': 1,
        });
        await localDataSource.addTenantPayment(syncedModel);
      }

      return const Right(null);
    } catch (e) {
      return const Left(ServerFailure());
    }
  }
}
