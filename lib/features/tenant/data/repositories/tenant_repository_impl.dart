import 'package:cloud_firestore/cloud_firestore.dart';
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

  // Lazy fail-safe property ID resolver
  Future<String> _getOrResolvePropertyId() async {
    String pId = await localStorageService.familyId ?? '';
    if (pId.isEmpty) {
      final uid = await localStorageService.userId ?? '';
      if (uid.isNotEmpty) {
        final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
        if (doc.exists && doc.data() != null) {
          final data = doc.data()!;
          pId = data['familyId'] as String? ?? '';
          if (pId.isNotEmpty) {
            await localStorageService.setFamilyId(pId);
          }
        }
      }
    }
    return pId;
  }

  // Properties
  @override
  Stream<Either<Failure, PropertyEntity?>> getProperty(String propertyId) {
    return remoteDataSource.getPropertyStream(propertyId).map((model) => Right(model));
  }

  @override
  Future<Either<Failure, void>> updateProperty(PropertyEntity property) async {
    try {
      final pId = await _getOrResolvePropertyId();
      final resolvedProp = property.id.isEmpty ? property.copyWith(id: pId) : property;
      await remoteDataSource.updateProperty(PropertyModel.fromEntity(resolvedProp));
      return const Right(null);
    } catch (e) {
      return const Left(UnexpectedFailure(description: 'Failed to update property details'));
    }
  }

  // Tenants
  @override
  Future<Either<Failure, void>> addTenant(TenantEntity tenant) async {
    try {
      final pId = await _getOrResolvePropertyId();
      final resolvedTenant = tenant.propertyId.isEmpty ? tenant.copyWith(propertyId: pId) : tenant;
      await remoteDataSource.addTenant(TenantModel.fromEntity(resolvedTenant));
      return const Right(null);
    } catch (e) {
      return const Left(UnexpectedFailure(description: 'Failed to add tenant'));
    }
  }

  @override
  Future<Either<Failure, void>> updateTenant(TenantEntity tenant) async {
    try {
      final pId = await _getOrResolvePropertyId();
      final resolvedTenant = tenant.propertyId.isEmpty ? tenant.copyWith(propertyId: pId) : tenant;
      await remoteDataSource.updateTenant(TenantModel.fromEntity(resolvedTenant));
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
    final propertyId = await _getOrResolvePropertyId();
    yield* remoteDataSource.getTenantsStream(propertyId).map((models) => Right(models));
  }

  // Rooms
  @override
  Stream<Either<Failure, List<RoomEntity>>> getRooms() async* {
    final propertyId = await _getOrResolvePropertyId();
    yield* remoteDataSource.getRoomsStream(propertyId).map((models) => Right(models));
  }

  @override
  Future<Either<Failure, void>> addRoom(RoomEntity room) async {
    try {
      final pId = await _getOrResolvePropertyId();
      final resolvedRoom = room.propertyId.isEmpty ? room.copyWith(propertyId: pId) : room;
      await remoteDataSource.addRoom(RoomModel.fromEntity(resolvedRoom));
      return const Right(null);
    } catch (e) {
      return const Left(UnexpectedFailure(description: 'Failed to add room'));
    }
  }

  @override
  Future<Either<Failure, void>> updateRoom(RoomEntity room) async {
    try {
      final pId = await _getOrResolvePropertyId();
      final resolvedRoom = room.propertyId.isEmpty ? room.copyWith(propertyId: pId) : room;
      await remoteDataSource.updateRoom(RoomModel.fromEntity(resolvedRoom));
      return const Right(null);
    } catch (e) {
      return const Left(UnexpectedFailure(description: 'Failed to update room'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteRoom(String roomId) async {
    try {
      await remoteDataSource.deleteRoom(roomId);
      return const Right(null);
    } catch (e) {
      return const Left(UnexpectedFailure(description: 'Failed to delete room'));
    }
  }

  // Electricity Readings
  @override
  Stream<Either<Failure, List<ElectricityReadingEntity>>> getElectricityReadings() async* {
    final propertyId = await _getOrResolvePropertyId();
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
      final pId = await _getOrResolvePropertyId();
      final resolvedBill = bill.propertyId.isEmpty ? bill.copyWith(propertyId: pId) : bill;
      await remoteDataSource.addBill(TenantBillModel.fromEntity(resolvedBill));
      return const Right(null);
    } catch (e) {
      return const Left(UnexpectedFailure(description: 'Failed to generate bill'));
    }
  }

  @override
  Future<Either<Failure, void>> updateTenantBill(TenantBillEntity bill) async {
    try {
      final pId = await _getOrResolvePropertyId();
      final resolvedBill = bill.propertyId.isEmpty ? bill.copyWith(propertyId: pId) : bill;
      await remoteDataSource.updateBill(TenantBillModel.fromEntity(resolvedBill));
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
    final propertyId = await _getOrResolvePropertyId();
    yield* remoteDataSource.getBillsStream(propertyId).map((models) => Right(models));
  }

  // Payments
  @override
  Future<Either<Failure, void>> addTenantPayment(TenantPaymentEntity payment) async {
    try {
      final pId = await _getOrResolvePropertyId();
      final resolvedPayment = payment.propertyId.isEmpty ? payment.copyWith(propertyId: pId) : payment;
      await remoteDataSource.addPayment(TenantPaymentModel.fromEntity(resolvedPayment));
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
    final propertyId = await _getOrResolvePropertyId();
    yield* remoteDataSource.getPaymentsStream(propertyId).map((models) => Right(models));
  }

  // Legacy sync - no op as Firestore is the real-time source of truth
  @override
  Future<Either<Failure, void>> syncWithFirebase() async {
    return const Right(null);
  }
}
