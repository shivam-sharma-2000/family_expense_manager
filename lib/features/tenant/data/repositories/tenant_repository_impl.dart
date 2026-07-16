import 'package:expense_manager/core/service/i_local_storage_service.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure/failure.dart';
import '../../domain/entities/tenant_entity.dart';
import '../../domain/entities/tenant_bill_entity.dart';
import '../../domain/entities/tenant_payment_entity.dart';
import '../../domain/entities/room_entity.dart';
import '../../domain/entities/electricity_reading_entity.dart';
import '../../domain/entities/property_entity.dart';
import '../../domain/repositories/tenant_repository.dart';
import '../datasources/remote/tenant_remote_data_source.dart';
import '../models/tenant_model.dart';
import '../models/tenant_bill_model.dart';
import '../models/tenant_payment_model.dart';
import '../models/room_model.dart';
import '../models/electricity_reading_model.dart';
import '../models/property_model.dart';

class TenantRepositoryImpl implements TenantRepository {
  final TenantRemoteDataSource remoteDataSource;
  final ILocalStorageService localStorageService;

  TenantRepositoryImpl({
    required this.remoteDataSource,
    required this.localStorageService,
  });

  // Properties
  @override
  Stream<Either<Failure, PropertyEntity?>> getProperty(String propertyId) {
    return remoteDataSource.getPropertyStream(propertyId).map((model) => Right(model));
  }

  @override
  Future<Either<Failure, void>> updateProperty(PropertyEntity property) async {
    try {
      await remoteDataSource.updateProperty(PropertyModel.fromEntity(property));
      return const Right(null);
    } catch (e) {
      return const Left(UnexpectedFailure(description: 'Failed to update property details'));
    }
  }

  // Tenants
  @override
  Future<Either<Failure, void>> addTenant(TenantEntity tenant) async {
    try {
      await remoteDataSource.addTenant(TenantModel.fromEntity(tenant));
      return const Right(null);
    } catch (e) {
      return const Left(UnexpectedFailure(description: 'Failed to add tenant'));
    }
  }

  @override
  Future<Either<Failure, void>> updateTenant(TenantEntity tenant) async {
    try {
      await remoteDataSource.updateTenant(TenantModel.fromEntity(tenant));
      return const Right(null);
    } catch (e) {
      return const Left(UnexpectedFailure(description: 'Failed to update tenant'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTenant(String tenantId) async {
    try {
      await remoteDataSource.deleteTenant(tenantId);
      return const Right(null);
    } catch (e) {
      return const Left(UnexpectedFailure(description: 'Failed to delete tenant'));
    }
  }

  @override
  Stream<Either<Failure, List<TenantEntity>>> getTenants() async* {
    final propertyId = await localStorageService.familyId ?? '';
    yield* remoteDataSource.getTenantsStream(propertyId).map((models) => Right(models));
  }

  // Rooms
  @override
  Stream<Either<Failure, List<RoomEntity>>> getRooms() async* {
    final propertyId = await localStorageService.familyId ?? '';
    yield* remoteDataSource.getRoomsStream(propertyId).map((models) => Right(models));
  }

  @override
  Future<Either<Failure, void>> addRoom(RoomEntity room) async {
    try {
      await remoteDataSource.addRoom(RoomModel.fromEntity(room));
      return const Right(null);
    } catch (e) {
      return const Left(UnexpectedFailure(description: 'Failed to add room'));
    }
  }

  @override
  Future<Either<Failure, void>> updateRoom(RoomEntity room) async {
    try {
      await remoteDataSource.updateRoom(RoomModel.fromEntity(room));
      return const Right(null);
    } catch (e) {
      return const Left(UnexpectedFailure(description: 'Failed to update room'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteRoom(String roomId) async {
    try {
      // Check if room occupied
      await remoteDataSource.deleteRoom(roomId);
      return const Right(null);
    } catch (e) {
      return const Left(UnexpectedFailure(description: 'Failed to delete room'));
    }
  }

  // Electricity Readings
  @override
  Stream<Either<Failure, List<ElectricityReadingEntity>>> getElectricityReadings() async* {
    final propertyId = await localStorageService.familyId ?? '';
    yield* remoteDataSource.getElectricityReadingsStream(propertyId).map((models) => Right(models));
  }

  @override
  Future<Either<Failure, void>> updateElectricityReading(ElectricityReadingEntity reading) async {
    try {
      await remoteDataSource.updateElectricityReading(ElectricityReadingModel.fromEntity(reading));
      return const Right(null);
    } catch (e) {
      return const Left(UnexpectedFailure(description: 'Failed to update electricity reading'));
    }
  }

  // Bills
  @override
  Future<Either<Failure, void>> addTenantBill(TenantBillEntity bill) async {
    try {
      await remoteDataSource.addBill(TenantBillModel.fromEntity(bill));
      return const Right(null);
    } catch (e) {
      return const Left(UnexpectedFailure(description: 'Failed to generate bill'));
    }
  }

  @override
  Future<Either<Failure, void>> updateTenantBill(TenantBillEntity bill) async {
    try {
      await remoteDataSource.updateBill(TenantBillModel.fromEntity(bill));
      return const Right(null);
    } catch (e) {
      return const Left(UnexpectedFailure(description: 'Failed to update bill'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTenantBill(String billId) async {
    try {
      await remoteDataSource.deleteBill(billId);
      return const Right(null);
    } catch (e) {
      return const Left(UnexpectedFailure(description: 'Failed to delete bill'));
    }
  }

  @override
  Stream<Either<Failure, List<TenantBillEntity>>> getTenantBills(String tenantId) {
    return remoteDataSource.getTenantBillsStream(tenantId).map((models) => Right(models));
  }

  @override
  Stream<Either<Failure, List<TenantBillEntity>>> getAllBills() async* {
    final propertyId = await localStorageService.familyId ?? '';
    yield* remoteDataSource.getBillsStream(propertyId).map((models) => Right(models));
  }

  // Payments
  @override
  Future<Either<Failure, void>> addTenantPayment(TenantPaymentEntity payment) async {
    try {
      await remoteDataSource.addPayment(TenantPaymentModel.fromEntity(payment));
      return const Right(null);
    } catch (e) {
      return const Left(UnexpectedFailure(description: 'Failed to record payment'));
    }
  }

  @override
  Stream<Either<Failure, List<TenantPaymentEntity>>> getTenantPayments(String tenantId) {
    return remoteDataSource.getTenantPaymentsStream(tenantId).map((models) => Right(models));
  }

  @override
  Stream<Either<Failure, List<TenantPaymentEntity>>> getAllPayments() async* {
    final propertyId = await localStorageService.familyId ?? '';
    yield* remoteDataSource.getPaymentsStream(propertyId).map((models) => Right(models));
  }

  // Legacy sync - no op as Firestore is the real-time source of truth
  @override
  Future<Either<Failure, void>> syncWithFirebase() async {
    return const Right(null);
  }
}
