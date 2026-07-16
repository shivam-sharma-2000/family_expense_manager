import '../../models/tenant_model.dart';
import '../../models/tenant_bill_model.dart';
import '../../models/tenant_payment_model.dart';
import '../../models/room_model.dart';
import '../../models/electricity_reading_model.dart';
import '../../models/property_model.dart';

abstract class TenantRemoteDataSource {
  // Properties
  Stream<PropertyModel?> getPropertyStream(String propertyId);
  Future<void> updateProperty(PropertyModel property);

  // Tenants
  Stream<List<TenantModel>> getTenantsStream(String propertyId);
  Future<void> addTenant(TenantModel tenant);
  Future<void> updateTenant(TenantModel tenant);
  Future<void> deleteTenant(String tenantId);

  // Rooms
  Stream<List<RoomModel>> getRoomsStream(String propertyId);
  Future<void> addRoom(RoomModel room);
  Future<void> updateRoom(RoomModel room);
  Future<void> deleteRoom(String roomId);

  // Electricity
  Stream<List<ElectricityReadingModel>> getElectricityReadingsStream(String propertyId);
  Future<void> updateElectricityReading(ElectricityReadingModel reading);

  // Bills
  Stream<List<TenantBillModel>> getBillsStream(String propertyId);
  Stream<List<TenantBillModel>> getTenantBillsStream(String tenantId);
  Future<void> addBill(TenantBillModel bill);
  Future<void> updateBill(TenantBillModel bill);
  Future<void> deleteBill(String billId);

  // Payments
  Stream<List<TenantPaymentModel>> getPaymentsStream(String propertyId);
  Stream<List<TenantPaymentModel>> getTenantPaymentsStream(String tenantId);
  Future<void> addPayment(TenantPaymentModel payment);
}
