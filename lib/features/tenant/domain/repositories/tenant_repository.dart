import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure/failure.dart';
import '../entities/tenant_entity.dart';
import '../entities/tenant_bill_entity.dart';
import '../entities/tenant_payment_entity.dart';
import '../entities/room_entity.dart';
import '../entities/electricity_reading_entity.dart';
import '../entities/property_entity.dart';

abstract class TenantRepository {
  // Properties
  Stream<Either<Failure, PropertyEntity?>> getProperty(String propertyId);
  Future<Either<Failure, void>> updateProperty(PropertyEntity property);

  // Tenant Operations
  Future<Either<Failure, void>> addTenant(TenantEntity tenant);
  Future<Either<Failure, void>> updateTenant(TenantEntity tenant);
  Future<Either<Failure, void>> deleteTenant(String tenantId);
  Stream<Either<Failure, List<TenantEntity>>> getTenants();
  
  // Rooms Operations
  Stream<Either<Failure, List<RoomEntity>>> getRooms();
  Future<Either<Failure, void>> addRoom(RoomEntity room);
  Future<Either<Failure, void>> updateRoom(RoomEntity room);
  Future<Either<Failure, void>> deleteRoom(String roomId);

  // Electricity Operations
  Stream<Either<Failure, List<ElectricityReadingEntity>>> getElectricityReadings();
  Future<Either<Failure, void>> updateElectricityReading(ElectricityReadingEntity reading);

  // Billing Operations
  Future<Either<Failure, void>> addTenantBill(TenantBillEntity bill);
  Future<Either<Failure, void>> updateTenantBill(TenantBillEntity bill);
  Future<Either<Failure, void>> deleteTenantBill(String billId);
  Stream<Either<Failure, List<TenantBillEntity>>> getTenantBills(String tenantId);
  Stream<Either<Failure, List<TenantBillEntity>>> getAllBills();

  // Payment Operations
  Future<Either<Failure, void>> addTenantPayment(TenantPaymentEntity payment);
  Stream<Either<Failure, List<TenantPaymentEntity>>> getTenantPayments(String tenantId);
  Stream<Either<Failure, List<TenantPaymentEntity>>> getAllPayments();

  // Legacy/Compatibility sync method
  Future<Either<Failure, void>> syncWithFirebase();
}
